#tag Class
Protected Class uci_shell
Inherits Shell
	#tag Event
		Sub DataAvailable()
		  unused_input=unused_input+Me.ReadAll
		  unused_input=unused_input.ReplaceLineEndings(EndOfLine.Unix)
		  Var un_len As Integer = unused_input.length
		  If un_len < 1 Then
		    Return
		  End If
		  Var last_line_is_partial As Boolean = unused_input.Right(1) <> AVW_util.get_unix_end_of_line
		  Var lines() As String
		  lines=unused_input.Split(AVW_util.get_unix_end_of_line)
		  unused_input=""
		  Var last_line_num As Integer=lines.LastRowIndex
		  If((last_line_num > -1) And last_line_is_partial) Then
		    unused_input=lines(last_line_num)
		    last_line_num=last_line_num-1
		  End If
		  Var pick_line As Integer
		  For pick_line=lines.FirstRowIndex To last_line_num
		    Var aline As String = lines(pick_line)
		    If aline.length> 0 Then
		      If app.settings.get_integer("debug_data_from_uci")>0 Then
		        app.outs("<"+aline)
		      End If
		      eater.recieve(aline.ToText)
		    End If
		  Next
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub Constructor(ahub as player_hub)
		  hub=ahub
		  ExecuteMode = Shell.ExecuteModes.Interactive
		  TimeOut = -1
		  eater=new uci_uciok_consumer(hub)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub send_line(astr as text)
		  If app.settings.get_integer("debug_data_to_uci")>0 Then
		    app.outs("uci>"+astr)
		  End If
		  WriteLine(astr)
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		eater As uci_consumer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected hub As player_hub
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected unused_input As String
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="TimeOut"
			Visible=true
			Group=""
			InitialValue=""
			Type="Integer"
			EditorType="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ExecuteMode"
			Visible=true
			Group=""
			InitialValue=""
			Type="ExecuteModes"
			EditorType="Enum"
			#tag EnumValues
				"0 - Synchronous"
				"1 - Asynchronous"
				"2 - Interactive"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="Arguments"
			Visible=true
			Group=""
			InitialValue=""
			Type="String"
			EditorType="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Backend"
			Visible=true
			Group=""
			InitialValue=""
			Type="String"
			EditorType="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Canonical"
			Visible=true
			Group=""
			InitialValue=""
			Type="Boolean"
			EditorType="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ExitCode"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Result"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="PID"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="IsRunning"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
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
