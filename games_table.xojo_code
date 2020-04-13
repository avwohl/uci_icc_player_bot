#tag Class
Protected Class games_table
	#tag Method, Flags = &h0
		Sub Constructor()
		  games=New Dictionary
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function count_games_being_played() As Integer
		  var matcher as games_matcher_count=new games_matcher_count
		  rem run matcher to apply matcher to each game, count stored in matcher
		  rem result always -1 as matcher never matches, is run for side effect
		  Var dummy_result As Integer=first_matching_game(matcher)
		  #Pragma Unused dummy_result
		  Return matcher.get_count
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function create_game(agame_num as integer) As ICC_connection.ICC_DG_data_game_unified
		  if games.haskey(agame_num) then
		    games.Remove(agame_num)
		  end if
		  return find_game(agame_num)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub delete(key as integer)
		  games.remove(key)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function find_game(agame_num as integer) As ICC_connection.ICC_DG_data_game_unified
		  var default_empty_game As ICC_connection.ICC_DG_data_game_unified=Nil
		  return games.Lookup(agame_num,default_empty_game)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function first_matching_game(amatcher as games_matcher) As Integer
		  rem return a game number ready to have a move computed or -1 if none
		  For Each key_variant As Variant In games.Keys
		    Var key As Integer=key_variant
		    Var agame As ICC_connection.ICC_DG_data_game_unified=games.lookup(key,Nil)
		    If agame=Nil Then
		      rem key present but nil game, should not happen, clean up
		      games.remove(key)
		      Continue
		    End If
		    If amatcher.match(key,agame) Then
		      Return key
		    End If
		  Next key_variant
		  Return -1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function first_ready_game() As ICC_connection.ICC_DG_data_game_unified
		  var matcher As games_matcher=New games_matcher_ready
		  var found As Integer=first_matching_game(matcher)
		  Return find_game(found)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub store_game(agame_num as integer, agame as ICC_connection.ICC_DG_data_game_unified)
		  games.value(agame_num)=agame
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h1
		Protected games As Dictionary
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
