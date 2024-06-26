/* Copyright 2024 Rirusha
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-only
 */

[GtkTemplate (ui = "/io/github/Rirusha/Foldy/ui/app-row.ui")]
public sealed class Foldy.AppRow: Adw.ActionRow {

    [GtkChild]
    unowned Gtk.Stack icon_stack;
    [GtkChild]
    unowned Gtk.Image icon_image;
    [GtkChild]
    unowned Gtk.CheckButton check_button;

    public string folder_id { get; construct; }

    public string app_id { get; construct; }

    public DesktopFileReader dfr { get; construct; }

    bool _selection_enabled = false;
    public bool selection_enabled {
        get {
            return _selection_enabled;
        }
        set {
            _selection_enabled = value;

            if (value) {
                icon_stack.visible_child_name = "check";

            } else {
                icon_stack.visible_child_name = "icon";
            }
        }
    }

    public AppRow (string folder_id, string app_id, DesktopFileReader dfr) {
        Object (folder_id: folder_id, app_id: app_id, dfr: dfr);
    }

    construct {
        title = dfr.read_name ();
        subtitle = app_id;

        string icon_name = dfr.read_icon_name ();
        if (icon_name.has_suffix (".png") ||
            icon_name.has_suffix (".jpg") ||
            icon_name.has_suffix (".jpeg")) {
                icon_image.set_from_file (icon_name);
            } else {
                icon_image.set_from_icon_name (icon_name);
            }

        activated.connect (() => {
            check_button.active = !check_button.active;
        });

        //  delete_button.clicked.connect (() => {
        //      remove_app_from_folder (folder_id, app_id);
        //  });
    }
}
