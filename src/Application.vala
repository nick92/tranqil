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

namespace Tranqil {

public class Application : Gtk.Application {

    private static Application app;
    private Window window = null;
    private Bus bus;

    public Application () {
        Object (application_id: "com.github.nick92.tranqil",
        flags: ApplicationFlags.FLAGS_NONE);
    }

    protected override void activate () {
        if (window != null) {
            window.present ();
            return;
        }

        window = new Window (this);

        var provider = new Gtk.CssProvider ();
        provider.load_from_resource ("com/github/nick92/tranqil/application.css");
        Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        window.delete_event.connect(window.main_quit);
        window.show_all ();

        //bus = new Bus (window.pipeline_forest);
    }

    public static Application get_instance () {
        if (app == null)
            app = new Application ();

        return app;
    }

    public static int main (string[] args) {
        Gst.init(ref args);
        app = new Application ();

        if (args[1] == "-s") {
            return 0;
        }

        return app.run (args);
    }
  }
}
