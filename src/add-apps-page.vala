/*
 * Copyright 2024 Rirusha
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

[GtkTemplate (ui = "/io/github/Rirusha/Foldy/ui/add-apps-page.ui")]
public sealed class Foldy.AddAppsPage : BasePage {

    [GtkChild]
    unowned Gtk.Button add_button;

    Array<AppRow> app_rows = new Array<AppRow> ();

    public string folder_id { get; construct; }

    public AddAppsPage (Adw.NavigationView nav_view, string folder_id) {
        Object (nav_view: nav_view, folder_id: folder_id);
    }

    construct {
        AppInfoMonitor.get ().changed.connect (refresh);

        add_button.clicked.connect (() => {
            add_apps_to_folder (folder_id, get_selected_apps ());
            selection_enabled = false;
            nav_view.pop ();
        });

        selection_enabled = true;
    }

    string[] get_selected_apps () {
        var row_ids = new Array<string> ();

        foreach (var row in app_rows.data) {
            var app_row = (AppRow) row;

            if (app_row.selected) {
                row_ids.append_val (app_row.app_info.get_id ());
            }
        }

        return row_ids.data;
    }

    protected override void update_list () {
        app_rows = new Array<AppRow> ();
        row_box.remove_all ();

        update_list_async.begin ();
    }

    async void update_list_async () {
        var app_infos = AppInfo.get_all ();
        var folder_apps = get_folder_apps (folder_id);

        foreach (AppInfo app_info in app_infos) {
            if (app_info.should_show ()) {
                var app_row = new AppRow (app_info);

                bind_property (
                    "selection-enabled",
                    app_row,
                    "selection-enabled",
                    BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE
                );

                app_row.notify ["selected"].connect (() => {
                    add_button.sensitive = get_selected_apps ().length != 0;
                });

                app_rows.append_val (app_row);
                row_box.append (app_row);

                if (app_info.get_id () in folder_apps) {
                    app_row.selected = true;
                    app_row.check_button_sensitive = false;
                }

                Idle.add (update_list_async.callback);
                yield;
            }
        }
    }

    protected override bool filter (Gtk.ListBoxRow row, string search_text) {
        var app_row = (AppRow) row;

        return search_text.down () in app_row.app_info.get_id ().down ();
    }
}