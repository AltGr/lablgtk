(* $Id$ *)

open Gaux
open Gtk
open GtkData
open GtkBase

(* Object *)

class gtkobj obj = object
  val obj = obj
  method destroy () = Object.destroy obj
  method get_type = Type.name (Object.get_type obj)
  method get_id = Object.get_id obj
end

class gtkobj_signals obj = object
  val obj = obj
  val after = false
  method after = {< after = true >}
  method destroy = GtkSignal.connect ~sgn:Object.Signals.destroy obj
  method disconnect = GtkSignal.disconnect obj
  method stop_emit ~name = GtkSignal.emit_stop_by_name obj ~name
end

(* Widget *)

class event_signals obj ~after = object
  val after = after
  val obj = Widget.coerce obj
  method any = GtkSignal.connect ~sgn:Widget.Signals.Event.any ~after obj
  method button_press =
    GtkSignal.connect ~sgn:Widget.Signals.Event.button_press ~after obj
  method button_release =
    GtkSignal.connect ~sgn:Widget.Signals.Event.button_release ~after obj
  method configure =
    GtkSignal.connect ~sgn:Widget.Signals.Event.configure ~after obj
  method delete =
    GtkSignal.connect ~sgn:Widget.Signals.Event.delete ~after obj
  method destroy =
    GtkSignal.connect ~sgn:Widget.Signals.Event.destroy ~after obj
  method enter_notify =
    GtkSignal.connect ~sgn:Widget.Signals.Event.enter_notify ~after obj
  method expose =
    GtkSignal.connect ~sgn:Widget.Signals.Event.expose ~after obj
  method focus_in =
    GtkSignal.connect ~sgn:Widget.Signals.Event.focus_in ~after obj
  method focus_out =
    GtkSignal.connect ~sgn:Widget.Signals.Event.focus_out ~after obj
  method key_press =
    GtkSignal.connect ~sgn:Widget.Signals.Event.key_press ~after obj
  method key_release =
    GtkSignal.connect ~sgn:Widget.Signals.Event.key_release ~after obj
  method leave_notify =
    GtkSignal.connect ~sgn:Widget.Signals.Event.leave_notify ~after obj
  method map = GtkSignal.connect ~sgn:Widget.Signals.Event.map ~after obj
  method motion_notify =
    GtkSignal.connect ~sgn:Widget.Signals.Event.motion_notify ~after obj
  method property_notify =
    GtkSignal.connect ~sgn:Widget.Signals.Event.property_notify ~after obj
  method proximity_in =
    GtkSignal.connect ~sgn:Widget.Signals.Event.proximity_in ~after obj
  method proximity_out =
    GtkSignal.connect ~sgn:Widget.Signals.Event.proximity_out ~after obj
  method selection_clear =
    GtkSignal.connect ~sgn:Widget.Signals.Event.selection_clear ~after obj
  method selection_notify =
    GtkSignal.connect ~sgn:Widget.Signals.Event.selection_notify ~after obj
  method selection_request =
    GtkSignal.connect ~sgn:Widget.Signals.Event.selection_request ~after obj
  method unmap = GtkSignal.connect ~sgn:Widget.Signals.Event.unmap ~after obj
end

class event_ops obj = object
  val obj = Widget.coerce obj
  method connect = new event_signals obj ~after:false
  method connect_after = new event_signals obj ~after:true
  method set_extensions = Widget.set_extension_events obj
end

class style st = object
  val style = st
  method as_style = style
  method copy = {< style = Style.copy style >}
  method bg state = Style.get_bg style ~state
  method colormap = Style.get_colormap style
  method font = Style.get_font style
  method set_bg =
    List.iter ~f:
      (fun (state,c) -> Style.set_bg style ~state ~color:(GDraw.color c))
  method set_font = Style.set_font style
  method set_background = Style.set_background style
end

class selection_data (sel : Selection.t) = object
  val sel = sel
  method selection = Selection.selection sel
  method target = Selection.target sel
  method seltype = Selection.seltype sel
  method format = Selection.format sel
  method data = Selection.get_data sel
  method set = Selection.set sel
end

class widget_drag obj = object
  val obj = Widget.coerce obj
  method dest_set ?(flags=[`ALL]) ?(actions=[]) targets =
    DnD.dest_set obj ~flags ~actions ~targets:(Array.of_list targets)
  method dest_unset () = DnD.dest_unset obj
  method get_data ?(time=0) ~context:(context : drag_context) target =
    DnD.get_data obj (context : < context : Gdk.drag_context; .. >)#context
      ~target ~time
  method highlight () = DnD.highlight obj
  method unhighlight () = DnD.unhighlight obj
  method source_set ?modi:m ?(actions=[]) targets =
    DnD.source_set obj ?modi:m ~actions ~targets:(Array.of_list targets)
  method source_set_icon ?(colormap = Gdk.Color.get_system_colormap ())
      (pix : GDraw.pixmap) =
    DnD.source_set_icon obj ~colormap pix#pixmap ?mask:pix#mask
  method source_unset () = DnD.source_unset obj
end

and drag_context context = object
  inherit GDraw.drag_context context
  method context = context
  method finish = DnD.finish context
  method source_widget =
    new widget (Object.unsafe_cast (DnD.get_source_widget context))
  method set_icon_widget (w : widget) =
    DnD.set_icon_widget context (w#as_widget)
  method set_icon_pixmap ?(colormap = Gdk.Color.get_system_colormap ())
      (pix : GDraw.pixmap) =
    DnD.set_icon_pixmap context ~colormap pix#pixmap ?mask:pix#mask
end

and widget_misc obj = object
  val obj = Widget.coerce obj
  method show () = Widget.show obj
  method unparent () = Widget.unparent obj
  method show_all () = Widget.show_all obj
  method hide () = Widget.hide obj
  method hide_all () = Widget.hide_all obj
  method map () = Widget.map obj
  method unmap () = Widget.unmap obj
  method realize () = Widget.realize obj
  method unrealize () = Widget.unrealize obj
  method draw = Widget.draw obj
  method event : Gdk.Tags.event_type Gdk.event -> bool = Widget.event obj
  method activate () = Widget.activate obj
  method reparent (w : widget) =  Widget.reparent obj w#as_widget
  method popup = Widget.popup obj
  method intersect = Widget.intersect obj
  method grab_focus () = Widget.grab_focus obj
  method grab_default () = Widget.grab_default obj
  method is_ancestor (w : widget) = Widget.is_ancestor obj w#as_widget
  method add_accelerator ~sgn:sg ~group ?modi:m ?flags key =
    Widget.add_accelerator obj ~sgn:sg group ~key ?modi:m ?flags
  method remove_accelerator = Widget.remove_accelerator obj
  method lock_accelerators () = Widget.lock_accelerators obj
  method set_name = Widget.set_name obj
  method set_state = Widget.set_state obj
  method set_sensitive = Widget.set_sensitive obj
  method set_extension_events = Widget.set_extension_events obj
  method set_can_default = Widget.set_can_default obj
  method set_can_focus = Widget.set_can_focus obj
  method set_uposition = Widget.set_uposition obj
  method set_usize = Widget.set_usize obj
  method set_style (style : style) = Widget.set_style obj style#as_style
  (* get functions *)
  method name = Widget.get_name obj
  method toplevel =
    try new widget (Object.unsafe_cast (Widget.get_toplevel obj))
    with Gpointer.Null -> raise Not_found
  method window = Widget.window obj
  method colormap = Widget.get_colormap obj
  method visual = Widget.get_visual obj
  method visual_depth = Gdk.Window.visual_depth (Widget.get_visual obj)
  method pointer = Widget.get_pointer obj
  method style = new style (Widget.get_style obj)
  method visible = Widget.visible obj
  method has_focus = Widget.has_focus obj
  method parent =
    try new widget (Object.unsafe_cast (Widget.parent obj))
    with Gpointer.Null -> raise Not_found
  method set_app_paintable = Widget.set_app_paintable obj
  method allocation = Widget.allocation obj
end

and widget obj = object (self)
  inherit gtkobj obj
  method as_widget = Widget.coerce obj
  method coerce = (self :> < destroy : _; get_type : _; get_id : _;
		             as_widget : _; coerce : _; misc : _; drag : _ >)
  method misc = new widget_misc obj
  method drag = new widget_drag (Object.unsafe_cast obj)
end

class drag_signals obj ~after = object
  val obj =  Widget.coerce obj
  val after = after
  method beginning ~callback =
    GtkSignal.connect ~sgn:Widget.Signals.drag_begin ~after obj
      ~callback:(fun context -> callback (new drag_context context))
  method ending ~callback =
    GtkSignal.connect ~sgn:Widget.Signals.drag_end ~after obj
      ~callback:(fun context -> callback (new drag_context context))
  method data_delete ~callback =
    GtkSignal.connect ~sgn:Widget.Signals.drag_data_delete ~after obj
      ~callback:(fun context -> callback (new drag_context context))
  method leave ~callback =
    GtkSignal.connect ~sgn:Widget.Signals.drag_leave ~after obj
      ~callback:(fun context -> callback (new drag_context context))
  method motion ~callback =
    GtkSignal.connect ~sgn:Widget.Signals.drag_motion ~after obj
      ~callback:(fun context -> callback (new drag_context context))
  method drop ~callback =
    GtkSignal.connect ~sgn:Widget.Signals.drag_drop ~after obj
      ~callback:(fun context -> callback (new drag_context context))
  method data_get ~callback =
    GtkSignal.connect ~sgn:Widget.Signals.drag_data_get ~after obj
      ~callback:(fun context data -> callback (new drag_context context)
	       (new selection_data data))
  method data_received ~callback =
    GtkSignal.connect ~sgn:Widget.Signals.drag_data_received ~after obj
      ~callback:(fun context ~x ~y data -> callback (new drag_context context)
	       ~x ~y (new selection_data data))

end

class widget_signals obj = object
  inherit gtkobj_signals obj
  method event = new event_signals obj ~after
  method drag = new drag_signals obj ~after
  method draw ~callback =
    GtkSignal.connect obj ~sgn:Widget.Signals.draw ~after ~callback:
      begin fun rect ->
	callback
	  { x = Gdk.Rectangle.x rect ; y = Gdk.Rectangle.y rect;
	    width = Gdk.Rectangle.width rect;
	    height = Gdk.Rectangle.height rect }
      end
  method realize = GtkSignal.connect ~sgn:Widget.Signals.realize ~after obj
  method show = GtkSignal.connect ~sgn:Widget.Signals.show ~after obj
  method parent_set ~callback =
    GtkSignal.connect obj ~sgn:Widget.Signals.parent_set ~after ~callback:
      begin function
	  None   -> callback None
	| Some w -> callback (Some (new widget (Object.unsafe_cast w)))
      end
end

class widget_full obj = object
  inherit widget obj
  method connect = new widget_signals obj
end

let as_widget (w : widget) = w#as_widget

let pack_return self ~packing ~show =
  may packing ~f:(fun f -> (f (self : #widget :> widget) : unit));
  if show <> Some false then self#misc#show ();
  self