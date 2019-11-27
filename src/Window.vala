/***

    Copyright (C) 2017 Tranqil Developers

    This program is free software: you can redistribute it and/or modify it
    under the terms of the GNU Lesser General Public License version 3, as
    published by the Free Software Foundation.

    This program is distributed in the hope that it will be useful, but
    WITHOUT ANY WARRANTY; without even the implied warranties of
    MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
    PURPOSE.  See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program.  If not, see <http://www.gnu.org/licenses>

***/

using Gtk;
using GLib;

namespace Tranqil {

    const int MIN_WIDTH = 100;
    const int MIN_HEIGHT = 100;

    public class Window : Gtk.Dialog {

        private GLib.Settings tranqil_settings;

        /* GUI components */
        private Gtk.Label                   tranqil_text;
        private Gtk.Label                   tranqil_text2;
        private Gtk.Grid                    grid;            // Container for everything
        private Gtk.Revealer                reveal;
        private Gtk.Revealer                reveal_1;
        private Gtk.Revealer                reveal_2;
        private Bus                         bus;

        private Gtk.SeparatorMenuItem   separator;
        private Gtk.MenuItem            item_clear_history;
        private Gtk.ToggleButton        toggle_forest;
        private Gtk.ToggleButton        toggle_night;
        private Gtk.ToggleButton        toggle_waves;
        private Gtk.ToggleButton        toggle_rain;
        private Gtk.Scale               volume1;
        private Gtk.Scale               volume2;
        private Gtk.Scale               volume3;
        private Gtk.Scale               volume4;
        private Gtk.Button              button_help;
        private Gtk.Button              img_about;
        private Gst.Pipeline            pipeline;
        public Gst.Element              pipeline_forest;
        private Gst.Element             pipeline_night;
        private Gst.Element             pipeline_waves;
        private Gst.Element             pipeline_rain;
        private Gtk.SpinButton          spin_button;
        Gst.Bus                         forest_bus;
        Gst.Bus                         night_bus;
        Gst.Bus                         sea_bus;
        Gst.Bus                         rain_bus;

        private signal void change_colour();

        private string color_primary;

        private const string COLOR_PRIMARY = """
          @define-color bg_color %s;
             .background,
             .titlebar {
                 transition: all 800ms ease-in-out;
             }
        """;

        private const string COLOR_PRIMARY_NIGHT = """
          @define-color bg_color shade (%s, %s);
             .background,
             .titlebar {
                 transition: all 800ms ease-in-out;
             }
        """;

        public Window (Gtk.Application application) {

            set_application(application);
            tranqil_settings = new GLib.Settings ("com.github.nick92.tranqil");

            // Set up geometry
            Gdk.Geometry geo = new Gdk.Geometry();
            geo.min_width = MIN_WIDTH;
            geo.min_height = MIN_HEIGHT;
            geo.max_width = 1024;
            geo.max_height = 648;

            this.set_geometry_hints(null, geo, Gdk.WindowHints.MIN_SIZE | Gdk.WindowHints.MAX_SIZE);

            restore_window_position ();

            grid = new Gtk.Grid ();
            reveal = new Gtk.Revealer ();
            reveal_1 = new Gtk.Revealer ();
            reveal_2 = new Gtk.Revealer ();

            setup_ui ();    // Set up the GUI
            player_init ();
            bus = new Bus (pipeline_forest, pipeline_night, pipeline_waves, pipeline_rain);
            connect_signals ();

        }

        /**
         * Builds all of the widgets and arranges them in the window.
         */
        private void setup_ui () {
            this.set_title ("tranqil");
            

            var provider = new Gtk.CssProvider ();
            provider.load_from_resource ("/com/github/nick92/tranqil/application.css");
            Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            
            var relax_label = new Gtk.Label (_("Choose sounds…"));
            relax_label.get_style_context ().add_class ("h2");
            relax_label.margin_bottom = 15;

            toggle_forest = new Gtk.ToggleButton ();
            toggle_night = new Gtk.ToggleButton ();
            toggle_waves = new Gtk.ToggleButton ();
            toggle_rain = new Gtk.ToggleButton ();

            toggle_forest.image = new Gtk.Image.from_resource ("/com/github/nick92/tranqil/icons/forest.svg");
            toggle_night.image = new Gtk.Image.from_resource ("/com/github/nick92/tranqil/icons/night.svg");
            toggle_waves.image = new Gtk.Image.from_resource ("/com/github/nick92/tranqil/icons/waves.svg");
            toggle_rain.image = new Gtk.Image.from_resource ("/com/github/nick92/tranqil/icons/rain.svg");

            /*toggle_forest.opacity = 0.9;
            toggle_night.opacity = 0.9;
            toggle_waves.opacity = 0.9;*/

            toggle_forest.add_events (Gdk.EventMask.SCROLL_MASK);
            toggle_night.add_events (Gdk.EventMask.SCROLL_MASK);
            toggle_waves.add_events (Gdk.EventMask.SCROLL_MASK);
            toggle_rain.add_events (Gdk.EventMask.SCROLL_MASK);

            //toggle_night.margin_top = 24;

            /*toggle_forest.halign = Gtk.Align.END;
            toggle_waves.halign = Gtk.Align.START;

            toggle_forest.valign = Gtk.Align.START;
            toggle_waves.valign = Gtk.Align.START;*/

            toggle_forest.get_style_context ().add_class ("button");
            toggle_night.get_style_context ().add_class ("button");
            toggle_waves.get_style_context ().add_class ("button");
            toggle_rain.get_style_context ().add_class ("button");

            button_help = new Gtk.Button ();
            //img_about = new Gtk.Button ();

            button_help.image = new Gtk.Image.from_icon_name ("help-contents-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
            button_help.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            button_help.valign = Gtk.Align.START;

            button_help.image = new Gtk.Image.from_icon_name ("help-contents-symbolic", Gtk.IconSize.DND);
            button_help.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            button_help.valign = Gtk.Align.START;
            button_help.tooltip_text = _("Display Help");

            var header = new Gtk.HeaderBar ();
            header.title = "tranqil";
            //header.show_close_button = true;
            //header.get_style_context ().add_class ("default-decoration");
            //header.pack_end (button_help);

            volume1 = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0, 8, 1);
            volume1.set_draw_value (false);
            volume1.set_value (7);
            volume1.round_digits = 0;

            volume2 = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0, 8, 1);
            volume2.set_draw_value (false);
            volume2.set_value (7);
            volume2.round_digits = 0;

            volume3 = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0, 8, 1);
            volume3.set_draw_value (false);
            volume3.set_value (7);
            volume3.round_digits = 0;

            volume4 = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0, 8, 1);
            volume4.set_draw_value (false);
            volume4.set_value (7);
            volume4.round_digits = 0;

            reveal.set_transition_duration (800);
            reveal_1.set_transition_duration (800);
            reveal_2.set_transition_duration (800);

            reveal_1.valign = Gtk.Align.START;
            reveal_2.valign = Gtk.Align.START;

            reveal_1.add(tranqil_text);
            reveal_2.add(tranqil_text2);

            grid.halign = Gtk.Align.CENTER;
            grid.valign = Gtk.Align.CENTER;
            grid.column_spacing = 50;
            grid.margin_bottom = 10;
            grid.margin_end = 20;
            grid.margin_start = 20;
            //grid.margin = 20;
            relax_label.halign = Gtk.Align.CENTER;
            grid.attach (relax_label, 1, 0, 4, 1);
            grid.attach (toggle_forest, 1, 1, 1, 1);
            //grid.attach (reveal_1, 0, 3, 1, 1);

            //grid.attach (nature_label, 1, 1, 1, 1);
            grid.attach (toggle_night, 2, 1, 1, 1);
            grid.attach (toggle_waves, 3, 1, 1, 1);
            grid.attach (toggle_rain, 4, 1, 1, 1);
            //grid.attach (reveal_2, 2, 3, 1, 1);
            //grid.attach (button_help, 3, 0, 1, 1);

            var stack = new Gtk.Stack ();
            stack.transition_type = Gtk.StackTransitionType.CROSSFADE;
            stack.vhomogeneous = true;
            stack.add_named (grid, "sounds");

            var content_box = get_content_area () as Gtk.Box;
            content_box.border_width = 0;
            content_box.add (stack);
            content_box.show_all ();

            var action_box = get_action_area () as Gtk.Box;
            action_box.visible = false;
        }

        public void player_init () {
          // Build the pipeline:
        	try {
        		pipeline_forest = Gst.parse_launch ("playbin uri=file:///usr/share/enso/tranqil/sounds/new/Waipoua-Forest-Wind.ogg");
            pipeline_forest.set("volume", 5.0);
            pipeline_night = Gst.parse_launch ("playbin uri=file:///usr/share/enso/tranqil/sounds/new/Whiritoa-Evening.ogg");
            pipeline_night.set("volume", 5.0);
            pipeline_waves = Gst.parse_launch ("playbin uri=file:///usr/share/enso/tranqil/sounds/new/Mahurangi-Waves.ogg");
            pipeline_waves.set("volume", 5.0);
            pipeline_rain = Gst.parse_launch ("playbin uri=file:///usr/share/enso/tranqil/sounds/new/rain.ogg");
            pipeline_rain.set("volume", 5.0);
        	} catch (Error e) {
        		stderr.printf ("Error: %s\n", e.message);
        	}
        }

        public void connect_signals () {

          forest_bus = pipeline_forest.get_bus ();
          forest_bus.add_signal_watch ();
          forest_bus.message.connect (bus.parse_message);

          night_bus = pipeline_night.get_bus ();
          night_bus.add_signal_watch ();
          night_bus.message.connect (bus.parse_message);

          sea_bus = pipeline_waves.get_bus ();
          sea_bus.add_signal_watch ();
          sea_bus.message.connect (bus.parse_message);

          rain_bus = pipeline_rain.get_bus ();
          rain_bus.add_signal_watch ();
          rain_bus.message.connect (bus.parse_message);

          volume1.value_changed.connect (() => {
            pipeline_forest.set("volume", volume1.get_value ());
            toggle_forest.opacity = volume1.get_value () / 10 + 0.2;
          });

          volume2.value_changed.connect (() => {
            pipeline_night.set("volume", volume2.get_value ());
            toggle_night.opacity = volume2.get_value () / 10 + 0.2;
          });

          volume3.value_changed.connect (() => {
            pipeline_waves.set("volume", volume3.get_value ());
            toggle_waves.opacity = volume3.get_value () / 10 + 0.2;
          });

          volume4.value_changed.connect (() => {
            pipeline_rain.set("volume", volume4.get_value ());
            toggle_rain.opacity = volume4.get_value () / 10 + 0.2;
          });

          change_colour.connect(() => {
            color_primary = change_background_colour();
            var provider = new Gtk.CssProvider ();
            var colored_css = "";
            try {
                if(toggle_night.active)
                  colored_css = COLOR_PRIMARY_NIGHT.printf (color_primary, "0.60");
                else
                  colored_css = COLOR_PRIMARY.printf (color_primary);

                provider.load_from_data (colored_css, colored_css.length);
                Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            } catch (GLib.Error e) {
                critical (e.message);
            }
          });

          toggle_forest.scroll_event.connect (on_scroll_event);
          toggle_night.scroll_event.connect (on_scroll_event_2);
          toggle_waves.scroll_event.connect (on_scroll_event_3);
          toggle_rain.scroll_event.connect (on_scroll_event_4);

          button_help.clicked.connect (() => {
            if(reveal.child_revealed) {
              reveal.set_reveal_child(false);
              reveal_1.set_reveal_child(false);
              reveal_2.set_reveal_child(false);
            }
            else {
              reveal.set_reveal_child(true);
              reveal_1.set_reveal_child(true);
              reveal_2.set_reveal_child(true);
            }
          });

          toggle_forest.toggled.connect (() => {
            if(toggle_forest.active){
              //toggle_forest.image = new Gtk.Image.from_file (Build.PKGDATADIR + "/icons/forest.svg");
              pipeline_forest.set_state (Gst.State.PLAYING);
              toggle_forest.get_style_context ().add_class ("activated");
            }
            else {
              //toggle_forest.image = new Gtk.Image.from_file (Build.PKGDATADIR + "/icons/forest-dark.svg");
              pipeline_forest.set_state (Gst.State.PAUSED);
              toggle_forest.get_style_context ().remove_class ("activated");
            }
            change_colour();
          });

          toggle_night.toggled.connect (() => {
            if(toggle_night.active){
              //toggle_night.image = new Gtk.Image.from_file (Build.PKGDATADIR + "/icons/night.svg");
              pipeline_night.set_state (Gst.State.PLAYING);
              toggle_night.get_style_context ().add_class ("activated");
            }
            else{
              //toggle_night.image = new Gtk.Image.from_file (Build.PKGDATADIR + "/icons/night-dark.svg");
              pipeline_night.set_state (Gst.State.PAUSED);
              toggle_night.get_style_context ().remove_class ("activated");
            }
            change_colour();
          });

          toggle_waves.toggled.connect (() => {
            if(toggle_waves.active){
              //toggle_waves.image = new Gtk.Image.from_file (Build.PKGDATADIR + "/icons/sea.svg");
              pipeline_waves.set_state (Gst.State.PLAYING);
              toggle_waves.get_style_context ().add_class ("activated");
            }
            else{
              //toggle_waves.image = new Gtk.Image.from_file (Build.PKGDATADIR + "/icons/sea-dark.svg");
              pipeline_waves.set_state (Gst.State.PAUSED);
              toggle_waves.get_style_context ().remove_class ("activated");
            }
            change_colour();
          });

          toggle_rain.toggled.connect (() => {
            if(toggle_rain.active){
              //toggle_night.image = new Gtk.Image.from_file (Build.PKGDATADIR + "/icons/night.svg");
              pipeline_rain.set_state (Gst.State.PLAYING);
              toggle_rain.get_style_context ().add_class ("activated");
            }
            else{
              //toggle_night.image = new Gtk.Image.from_file (Build.PKGDATADIR + "/icons/night-dark.svg");
              pipeline_rain.set_state (Gst.State.PAUSED);
              toggle_rain.get_style_context ().remove_class ("activated");
            }
            change_colour();
          });
        }

        private string change_background_colour (){
          if(toggle_forest.active && toggle_rain.active && toggle_waves.active)
            return "#33AA99";
          if(toggle_forest.active && toggle_waves.active)
            return "#15BCAF";
          if(toggle_rain.active && toggle_waves.active)
            return "#10819B";
          if(toggle_forest.active)
            return "#569151";
          if(toggle_rain.active)
            return "#295268";
          if(toggle_waves.active)
            return  "#1FA5C9";
          if(toggle_night.active)
            return "#ed2525";

          return "#7b4397";
        }

        private bool on_scroll_event (Gdk.EventScroll e) {

          //stderr.printf(e.direction.to_string ());
          if(e.direction == Gdk.ScrollDirection.UP)
            volume1.move_slider(Gtk.ScrollType.STEP_DOWN);
          if(e.direction == Gdk.ScrollDirection.DOWN)
            volume1.move_slider(Gtk.ScrollType.STEP_UP);

          return true;
        }

        private bool on_scroll_event_2 (Gdk.EventScroll e) {

          //stderr.printf(e.direction.to_string ());
          if(e.direction == Gdk.ScrollDirection.UP)
            volume2.move_slider(Gtk.ScrollType.STEP_DOWN);
          if(e.direction == Gdk.ScrollDirection.DOWN)
            volume2.move_slider(Gtk.ScrollType.STEP_UP);

          return true;
        }

        private bool on_scroll_event_3 (Gdk.EventScroll e) {

          //stderr.printf(e.direction.to_string ());
          if(e.direction == Gdk.ScrollDirection.UP)
            volume3.move_slider(Gtk.ScrollType.STEP_DOWN);
          if(e.direction == Gdk.ScrollDirection.DOWN)
            volume3.move_slider(Gtk.ScrollType.STEP_UP);

          return true;
        }

        private bool on_scroll_event_4 (Gdk.EventScroll e) {

          //stderr.printf(e.direction.to_string ());
          if(e.direction == Gdk.ScrollDirection.UP)
            volume4.move_slider(Gtk.ScrollType.STEP_DOWN);
          if(e.direction == Gdk.ScrollDirection.DOWN)
            volume4.move_slider(Gtk.ScrollType.STEP_UP);

          return true;
        }

        /**
         *  Restore window position.
         */
        public void restore_window_position () {
            var position = tranqil_settings.get_value ("window-position");
            var win_size = tranqil_settings.get_value ("window-size");

            if (position.n_children () == 2) {
                var x = (int32) position.get_child_value (0);
                var y = (int32) position.get_child_value (1);

                debug ("Moving window to coordinates %d, %d", x, y);
                this.move (x, y);
            } else {
                debug ("Moving window to the centre of the screen");
                this.window_position = Gtk.WindowPosition.CENTER;
            }

            if (win_size.n_children () == 2) {
                var width =  (int32) win_size.get_child_value (0);
                                var height = (int32) win_size.get_child_value (1);

                                debug ("Resizing to width and height: %d, %d", width, height);
                this.resize (width, height);
            } else {
                debug ("Not resizing window");
            }
        }

        /**
         *  Save window position.
         */
        public void save_window_position () {
            int x, y, width, height;
            this.get_position (out x, out y);
            this.get_size (out width, out height);
            debug ("Saving window position to %d, %d", x, y);
            tranqil_settings.set_value ("window-position", new int[] { x, y });
            debug ("Saving window size of width and height: %d, %d", width, height);
            tranqil_settings.set_value ("window-size", new int[] { width, height });
        }

        /**
         *  Quit from the program.
         */
        public bool main_quit () {
            save_window_position ();
            this.destroy ();

            return false;
        }
    }
}
