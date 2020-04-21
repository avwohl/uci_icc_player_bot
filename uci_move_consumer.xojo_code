#tag Class
Protected Class uci_move_consumer
Inherits uci_consumer
	#tag Method, Flags = &h0
		Sub recieve(mesg as text)
		  // Calling the overridden superclass method.
		  rem Super.recieve(mesg)
		  If mesg="bestmove (none)" Then
		    app.warning("cleared game for (none)")
		    hub.invalidate_current_game
		    Return
		  End If
		  Var reg As New RegEx
		  // reg.SearchPattern="bestmove\s+([a-h1-8]+)"
		  // alow specifying queening character
		  reg.SearchPattern="bestmove\s+(.+)"
		  Var move_match As RegExMatch
		  move_match=reg.search(mesg)
		  If move_match=Nil Then
		    app.warning("ignore uci response :"+mesg)
		    Return
		  End If
		  Var move As Text=move_match.SubExpressionString(1).ToText
		  rem pass move back to chess server
		  hub.make_this_move(move)
		  
		End Sub
	#tag EndMethod


	#tag ViewBehavior
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
