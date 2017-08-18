/***

    Copyright (C) 2017 Tranquil Developers

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

namespace Tranquil {

    const int MIN_WIDTH = 100;
    const int MIN_HEIGHT = 100;

    public class TranquilWindow : Gtk.Window {

        private GLib.Settings tranquil_settings = new GLib.Settings ("com.enso.tranquil");

        private enum Columns {
            TOGGLE,
            TEXT,
            STRIKETHROUGH,
            DELETE,
            DEL_VISIBLE,
            DRAGHANDLE,
            N_COLUMNS
        }

        /* GUI components */
        private Gtk.Label                   tranquil_text;
        private Gtk.Label                   tranquil_text2;
        private Gtk.Grid                    grid;            // Container for everything
        private Gtk.Revealer                reveal;
        private Gtk.Revealer                reveal_1;
        private Gtk.Revealer                reveal_2;
        private Granite.Widgets.AboutDialog aboutDialog;
        private TranBus                     tranBus;

        private Gtk.SeparatorMenuItem   separator;
        private Gtk.MenuItem            item_clear_history;
        private Gtk.ToggleButton        toggle_button_1;
        private Gtk.ToggleButton        toggle_button_2;
        private Gtk.ToggleButton        toggle_button_3;
        private Gtk.Scale               volume1;
        private Gtk.Scale               volume2;
        private Gtk.Scale               volume3;
        private Gtk.Button              button_help;
        private Gtk.Button              img_about;
        private Gst.Pipeline            pipeline;
        public Gst.Element              pipeline_forest;
        private Gst.Element             pipeline_night;
        private Gst.Element             pipeline_sea;
        private Gtk.SpinButton          spin_button;
        Gst.Bus                         forest_bus;
        Gst.Bus                         night_bus;
        Gst.Bus                         sea_bus;

        public TranquilWindow () {

            const string ELEMENTARY_STYLESHEET = """
                .titlebar {
                    background-color: @bg_color;
                    background-image: none;
                    border: none;
                }

                GtkToggleButton {
                  border-radius: 50%;
                }
            """;

            Granite.Widgets.Utils.set_theming_for_screen (this.get_screen (), ELEMENTARY_STYLESHEET,
                                               Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

            this.get_style_context ().add_class ("rounded");

            this.set_size_request(MIN_WIDTH, MIN_HEIGHT);

            // Set up geometry
            Gdk.Geometry geo = new Gdk.Geometry();
            geo.min_width = MIN_WIDTH;
            geo.min_height = MIN_HEIGHT;
            geo.max_width = 1024;
            geo.max_height = 648;

            this.set_geometry_hints(null, geo, Gdk.WindowHints.MIN_SIZE | Gdk.WindowHints.MAX_SIZE);

            restore_window_position ();

            var first = tranquil_settings.get_boolean ("first-time");

            /**
             *  Initialize the GUI components
             */
            tranquil_text = new Gtk.Label ("Select an image to play the sound");
            tranquil_text.justify = Gtk.Justification.CENTER;
            tranquil_text.wrap = true;
            tranquil_text.get_style_context ().add_class ("h2");

            tranquil_text2 = new Gtk.Label ("Scroll on image to adjust volume");
            tranquil_text2.justify = Gtk.Justification.CENTER;
            tranquil_text2.wrap = true;
            tranquil_text2.get_style_context ().add_class ("h2");

            grid = new Gtk.Grid ();
            reveal = new Gtk.Revealer ();
            reveal_1 = new Gtk.Revealer ();
            reveal_2 = new Gtk.Revealer ();

            setup_ui ();    // Set up the GUI
            player_init ();
            tranBus = new TranBus (pipeline_forest, pipeline_night, pipeline_sea);
            connect_signals ();
        }

        /**
         * Builds all of the widgets and arranges them in the window.
         */
        private void setup_ui () {
            this.set_title ("Tranquil");

            var relax_label = new Gtk.Label ("Relax..");
            relax_label.get_style_context ().add_class ("h1");

            var nature_label = new Gtk.Label ("To Nature");
            nature_label.get_style_context ().add_class ("h2");
            nature_label.get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);

            toggle_button_1 = new Gtk.ToggleButton ();
            toggle_button_2 = new Gtk.ToggleButton ();
            toggle_button_3 = new Gtk.ToggleButton ();

            toggle_button_1.image = new Gtk.Image.from_file (Build.PKGDATADIR + "/icons/forest-dark.svg");
            toggle_button_2.image = new Gtk.Image.from_file (Build.PKGDATADIR + "/icons/night-dark.svg");
            toggle_button_3.image = new Gtk.Image.from_file (Build.PKGDATADIR + "/icons/sea-dark.svg");

            toggle_button_1.opacity = 0.9;
            toggle_button_2.opacity = 0.9;
            toggle_button_3.opacity = 0.9;

            toggle_button_1.add_events (Gdk.EventMask.SCROLL_MASK);
            toggle_button_2.add_events (Gdk.EventMask.SCROLL_MASK);
            toggle_button_3.add_events (Gdk.EventMask.SCROLL_MASK);

            toggle_button_2.margin_top = 24;

            toggle_button_1.halign = Gtk.Align.END;
            toggle_button_3.halign = Gtk.Align.START;

            toggle_button_1.valign = Gtk.Align.START;
            toggle_button_3.valign = Gtk.Align.START;

            toggle_button_1.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            toggle_button_2.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            toggle_button_3.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

            button_help = new Gtk.Button ();
            //img_about = new Gtk.Button ();

<<<<<<< HEAD
            button_help.image = new Gtk.Image.from_icon_name ("help-contents-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
            button_help.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            button_help.valign = Gtk.Align.START;
=======
            button_help.image = new Gtk.Image.from_icon_name ("help-contents-symbolic", Gtk.IconSize.DND);
            button_help.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            button_help.valign = Gtk.Align.START;
            //img_about.image = new Gtk.Image.from_file (Build.PKGDATADIR + "/icons/info.svg");
            //img_about.tooltip_text = "Display About";
>>>>>>> 51a183799e0b88c9e74e9c7cfd8af25a9ad18659
            button_help.tooltip_text = "Display Help";

            var header = new Gtk.HeaderBar ();
            header.show_close_button = true;
            header.get_style_context ().add_class ("default-decoration");
            header.pack_end (button_help);

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

            reveal.set_transition_duration (800);
            reveal_1.set_transition_duration (800);
            reveal_2.set_transition_duration (800);

            reveal_1.valign = Gtk.Align.START;
            reveal_2.valign = Gtk.Align.START;

            reveal_1.add(tranquil_text);
            reveal_2.add(tranquil_text2);

            grid.halign = Gtk.Align.CENTER;
            grid.valign = Gtk.Align.CENTER;
            grid.margin = 12;
            grid.attach (toggle_button_1, 0, 0, 1, 3);
            grid.attach (reveal_1, 0, 3, 1, 1);
            grid.attach (relax_label, 1, 0, 1, 1);
            grid.attach (nature_label, 1, 1, 1, 1);
            grid.attach (toggle_button_2, 1, 2, 1, 1);
            grid.attach (toggle_button_3, 2, 0, 1, 3);
            grid.attach (reveal_2, 2, 3, 1, 1);
            grid.attach (button_help, 3, 0, 1, 1);
<<<<<<< HEAD
            
            set_titlebar (header);
=======

>>>>>>> 51a183799e0b88c9e74e9c7cfd8af25a9ad18659
            this.add (grid);
        }

        public void player_init () {
          // Build the pipeline:
        	try {
        		pipeline_forest = Gst.parse_launch ("playbin uri=file://" + Build.PKGDATADIR + "/sounds/amb-forest-spring-afternoon-02.ogg");
            pipeline_forest.set("volume", 5.0);
            pipeline_night = Gst.parse_launch ("playbin uri=file://" + Build.PKGDATADIR + "/sounds/countryside-summer-evening.ogg");
            pipeline_night.set("volume", 5.0);
            pipeline_sea = Gst.parse_launch ("playbin uri=file://" + Build.PKGDATADIR + "/sounds/waves-and-birdsong.ogg");
            pipeline_sea.set("volume", 5.0);
        	} catch (Error e) {
        		stderr.printf ("Error: %s\n", e.message);
        	}
        }

        public void connect_signals () {

          forest_bus = pipeline_forest.get_bus ();
          forest_bus.add_signal_watch ();
          forest_bus.message.connect (tranBus.parse_message);

          night_bus = pipeline_night.get_bus ();
          night_bus.add_signal_watch ();
          night_bus.message.connect (tranBus.parse_message);

          sea_bus = pipeline_sea.get_bus ();
          sea_bus.add_signal_watch ();
          sea_bus.message.connect (tranBus.parse_message);

          volume1.value_changed.connect (() => {
            pipeline_forest.set("volume", volume1.get_value ());
            toggle_button_1.opacity = volume1.get_value () / 10 + 0.2;
          });

          volume2.value_changed.connect (() => {
            pipeline_night.set("volume", volume2.get_value ());
            toggle_button_2.opacity = volume2.get_value () / 10 + 0.2;
          });

          volume3.value_changed.connect (() => {
            pipeline_sea.set("volume", volume3.get_value ());
            toggle_button_3.opacity = volume3.get_value () / 10 + 0.2;
          });

          toggle_button_1.scroll_event.connect (on_scroll_event);
          toggle_button_2.scroll_event.connect (on_scroll_event_2);
          toggle_button_3.scroll_event.connect (on_scroll_event_3);

          toggle_button_1.toggled.connect (() => {
            if(toggle_button_1.active){
              toggle_button_1.image = new Gtk.Image.from_file (Build.PKGDATADIR + "/icons/forest.svg");
              pipeline_forest.set_state (Gst.State.PLAYING);
            }
            else {
              toggle_button_1.image = new Gtk.Image.from_file (Build.PKGDATADIR + "/icons/forest-dark.svg");
              pipeline_forest.set_state (Gst.State.PAUSED);
            }
          });

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

          /*img_about.clicked.connect (() => {
            launch_about_dialoug ();
          });*/

          toggle_button_2.toggled.connect (() => {
            if(toggle_button_2.active){
              toggle_button_2.image = new Gtk.Image.from_file (Build.PKGDATADIR + "/icons/night.svg");
              pipeline_night.set_state (Gst.State.PLAYING);
            }
            else{
              toggle_button_2.image = new Gtk.Image.from_file (Build.PKGDATADIR + "/icons/night-dark.svg");
              pipeline_night.set_state (Gst.State.PAUSED);
            }
          });

          toggle_button_3.toggled.connect (() => {
            if(toggle_button_3.active){
              toggle_button_3.image = new Gtk.Image.from_file (Build.PKGDATADIR + "/icons/sea.svg");
              pipeline_sea.set_state (Gst.State.PLAYING);
            }
            else{
              toggle_button_3.image = new Gtk.Image.from_file (Build.PKGDATADIR + "/icons/sea-dark.svg");
              pipeline_sea.set_state (Gst.State.PAUSED);
            }
          });
        }

        private void launch_about_dialoug () {

          aboutDialog = new Granite.Widgets.AboutDialog ();
          //aboutDialog.set_parent_window (TranquilWindow);
          aboutDialog.help = "https://github.com/nick92/tranqil";
          aboutDialog.bug = "https://github.com/nick92/tranqil/issues";
          aboutDialog.translate = "https://github.com/nick92/tranqil/issues";
          aboutDialog.program_name = "Tranquil";
          aboutDialog.artists = {"fred", "buck"};
          aboutDialog.authors = {"Nick Wilkins"};
          aboutDialog.version = "0.1";
          aboutDialog.website = "https://github.com/nick92/tranqil";
          aboutDialog.website_label = "Github Page";

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

        /**
         *  Restore window position.
         */
        public void restore_window_position () {
            var position = tranquil_settings.get_value ("window-position");
            var win_size = tranquil_settings.get_value ("window-size");

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
            tranquil_settings.set_value ("window-position", new int[] { x, y });
            debug ("Saving window size of width and height: %d, %d", width, height);
            tranquil_settings.set_value ("window-size", new int[] { width, height });
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
