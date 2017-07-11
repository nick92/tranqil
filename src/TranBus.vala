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

using Gst;

namespace Tranquil {

  public class TranBus {

    private Element pipeline_forest;
    private Element pipeline_night;
    private Element pipeline_sea;

    public TranBus (Element pipeline_forest, Element pipeline_night, Element pipeline_sea) {
        this.pipeline_forest = pipeline_forest;
        this.pipeline_night = pipeline_night;
        this.pipeline_sea = pipeline_sea;
    }

    public void parse_message (Message message){
      //stdout.printf ("Pipeline state changed");
      if (message != null) {
        switch (message.type) {
        case Gst.MessageType.ERROR:
          GLib.Error err;
          string debug_info;

          message.parse_error (out err, out debug_info);
          stderr.printf ("Error received from element %s: %s\n", message.src.name, err.message);
          stderr.printf ("Debugging information: %s\n", (debug_info != null)? debug_info : "none");
          break;

        case Gst.MessageType.EOS:
          stdout.puts ("End-Of-Stream reached.\n");

          if(message.src == this.pipeline_forest){
            this.pipeline_forest.seek_simple (Gst.Format.TIME,  Gst.SeekFlags.FLUSH | Gst.SeekFlags.KEY_UNIT, 0);
            this.pipeline_forest.set_state (Gst.State.PLAYING);
          }

          if(message.src == this.pipeline_night){
            this.pipeline_night.seek_simple (Gst.Format.TIME,  Gst.SeekFlags.FLUSH | Gst.SeekFlags.KEY_UNIT, 0);
            this.pipeline_night.set_state (Gst.State.PLAYING);
          }

          if(message.src == this.pipeline_sea){
            this.pipeline_sea.seek_simple (Gst.Format.TIME,  Gst.SeekFlags.FLUSH | Gst.SeekFlags.KEY_UNIT, 0);
            this.pipeline_sea.set_state (Gst.State.PLAYING);
          }
          break;

        case Gst.MessageType.STATE_CHANGED:
          // We are only interested in state-changed messages from the pipeline:
          //if (message.src == this.pipeline_forest) {
            Gst.State old_state;
            Gst.State new_state;
            Gst.State pending_state;

            message.parse_state_changed (out old_state, out new_state, out pending_state);
            /*stdout.printf ("Pipeline state changed from %s to %s\n",
              Gst.Element.state_get_name (old_state),
              Gst.Element.state_get_name (new_state));*/
          //}
          break;

        //default:
          //We should not reach here:
          //assert_not_reached ();
        }
      }
    }

    /*public void message_night (Message message){
      //stdout.printf ("Pipeline state changed");
      if (message != null) {
        switch (message.type) {
        case Gst.MessageType.ERROR:
          GLib.Error err;
          string debug_info;

          message.parse_error (out err, out debug_info);
          stderr.printf ("Error received from element %s: %s\n", message.src.name, err.message);
          stderr.printf ("Debugging information: %s\n", (debug_info != null)? debug_info : "none");
          break;

        case Gst.MessageType.EOS:
          stdout.puts ("End-Of-Stream reached.\n");
          this.pipeline_night.seek_simple (Gst.Format.TIME,  Gst.SeekFlags.FLUSH | Gst.SeekFlags.KEY_UNIT, 0);
          this.pipeline_night.set_state (Gst.State.PLAYING);
          break;

        case Gst.MessageType.STATE_CHANGED:
          // We are only interested in state-changed messages from the pipeline:
          if (message.src == this.pipeline_night) {
            Gst.State old_state;
            Gst.State new_state;
            Gst.State pending_state;

            message.parse_state_changed (out old_state, out new_state, out pending_state);
            stdout.printf ("Pipeline state changed from %s to %s\n",
              Gst.Element.state_get_name (old_state),
              Gst.Element.state_get_name (new_state));
          }
          break;

        //default:
          //We should not reach here:
          //assert_not_reached ();
        }
      }
    }

    public void message_sea (Message message){
      //stdout.printf ("Pipeline state changed");
      if (message != null) {
        switch (message.type) {
        case Gst.MessageType.ERROR:
          GLib.Error err;
          string debug_info;

          message.parse_error (out err, out debug_info);
          stderr.printf ("Error received from element %s: %s\n", message.src.name, err.message);
          stderr.printf ("Debugging information: %s\n", (debug_info != null)? debug_info : "none");
          break;

        case Gst.MessageType.EOS:
          stdout.puts ("End-Of-Stream reached.\n");
          pipeline_sea.seek_simple (Gst.Format.TIME,  Gst.SeekFlags.FLUSH | Gst.SeekFlags.KEY_UNIT, 0);
          pipeline_sea.set_state (Gst.State.PLAYING);
          break;

        case Gst.MessageType.STATE_CHANGED:
          // We are only interested in state-changed messages from the pipeline:
          if (message.src == pipeline_sea) {
            Gst.State old_state;
            Gst.State new_state;
            Gst.State pending_state;

            message.parse_state_changed (out old_state, out new_state, out pending_state);
            stdout.printf ("Pipeline state changed from %s to %s\n",
              Gst.Element.state_get_name (old_state),
              Gst.Element.state_get_name (new_state));
          }
          break;

        //default:
          //We should not reach here:
          //assert_not_reached ();
        }
      }
    }*/
  }
}
