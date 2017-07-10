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

using Gtk;
using Granite;

namespace Tranquil {

public class Tranquil : Gtk.Application {

    private static Tranquil app;
    private TranquilWindow window = null;

    public Tranquil () {
        Object (application_id: "com.enso.tranquil",
        flags: ApplicationFlags.FLAGS_NONE);
    }

    protected override void activate () {
        if (window != null) {
            window.present ();
            return;
        }

        window = new TranquilWindow ();
        window.set_application (this);
        window.delete_event.connect(window.main_quit);
        window.show_all ();
    }

    public static Tranquil get_instance () {
        if (app == null)
            app = new Tranquil ();

        return app;
    }

    public static int main (string[] args) {
        Intl.setlocale (LocaleCategory.ALL, "");
        Intl.bind_textdomain_codeset (Build.GETTEXT_PACKAGE, "UTF-8");
        Intl.textdomain (Build.GETTEXT_PACKAGE);

        Gst.init(ref args);
        app = new Tranquil ();

        if (args[1] == "-s") {
            return 0;
        }

        return app.run (args);
    }
}
}
