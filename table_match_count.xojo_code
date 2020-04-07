#tag Class
Protected Class table_match_count
Inherits table_match
	#tag Method, Flags = &h0
		Sub Constructor()
		  number_of_games=0
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function get_count() As integer
		  return number_of_games
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function match(key as integer, agame as ICC_DG_data_game_unified) As boolean
		  // Calling the overridden superclass method.
		  rem Super.match(key, agame)
		  #pragma unused key
		  if agame.being_played then
		    number_of_games=number_of_games+1
		  end if
		  Return False
		End Function
	#tag EndMethod


	#tag Property, Flags = &h1
		Protected number_of_games As Integer
	#tag EndProperty


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
