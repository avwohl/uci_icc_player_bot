#tag Class
Protected Class player_hub
Inherits ICC_Hub
	#tag Method, Flags = &h0
		Sub ask_keepalive(user_name as string)
		  send_line("/tell "+user_name+" keep_alive")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub clear_current_game()
		  current_game=Nil
		  current_game_timeout=0
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor()
		  rem allow connect to have the full keepalive time to work
		  got_keep_alive
		  rem send a keepalive request as soon as possible
		  update_next_keep_alive_ticks_time=0
		  games=New table_of_games
		  clear_current_game
		  dg_map=new ICC_DG_debug
		  xcn_map=new ICC_XCN_debug
		  icc_net=new ICC_Net(SELF)
		  chess_shell=New uci_shell(Self)
		  start_uci_bot
		  chess_shell.send_line(app.settings.get_string("uci_startup").ToText)
		  startup
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub debug_print(atxt as text)
		  If app.settings.get_integer("debug_print")>0 Then
		    app.outs(atxt)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub handle_timeouts()
		  timeout_current_game
		  Super.handle_timeouts
		  If Not chess_shell.IsRunning Then
		    app.fatal_error("chess shell stopped")
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub invalidate_current_game()
		  If current_game<>Nil Then
		    Var game_num As Integer=current_game.get_game_started.game_num
		    games.delete(game_num)
		  End If
		  clear_current_game
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function jam(jam_code as integer, jam_text as text) As Boolean
		  // Calling the overridden superclass method.
		  var result as boolean = Super.jam(jam_code,jam_text)
		  var jam_str as text = Str(jam_code).ToText
		  var space_string as string = " "
		  var jam_out as text = jam_text + space_string.ToText + jam_str
		  debug_print(jam_out)
		  return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub make_connection()
		  rem hub=new XojoTestBot_Hub(SELF)
		  iccnet.start_connection(app.settings.get_integer("icc_port"),app.settings.get_string("icc_hostname"))
		  debug_print("started net connection")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub make_this_move(amove as text)
		  If current_game = Nil Then
		    Return
		  end if
		  send_line(amove)
		  Var jbo As ICC_DG_data_jboard=current_game.get_jboard
		  Var rel As ICC_DG_data_game_relation=current_game.get_game_relation
		  jbo.set_color_on_move(rel.get_opponent_color)
		  clear_current_game
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub NetEventDataReceived_disabled()
		  debug_print_string("DataReceived event")
		  rem super.NetEventDataReceived
		  ICC_Hub.NetEventDataReceived
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub NetEventError(err as RuntimeException)
		  rem err doesn't seem to have any data to print
		  #pragma Unused err
		  debug_print("NetEventError a RuntimeException")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub NetEventSendCompleted(userAborted as Boolean)
		  #pragma Unused userAborted
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function NetEventSendProgressed(bytesSent as Integer, bytesLeft as Integer) As Boolean
		  #pragma Unused bytesSent
		  #pragma Unused bytesLeft
		  rem return false to keep going true to quit sending
		  return false
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub parse_failed(atext as text)
		  debug_print("parse failed error="+atext)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub pick_a_move()
		  rem if we already are working on a move, when it comes it we will pick a new one
		  If current_game<>Nil Then
		    Return
		  End If
		  Var agame As ICC_DG_data_game_unified = games.first_ready_game
		  If agame = Nil Then
		    Return
		  End If
		  Var jboard As ICC_DG_data_jboard=agame.get_jboard
		  Var board As String = jboard.board
		  Var fen_board As Text=""
		  Var blank_count As Integer=0
		  For offset As Integer = 0 To 63
		    Var ch As Text = board.Middle(offset,1).ToText
		    If (ch = "-") Then
		      blank_count=blank_count+1
		    Else
		      If(blank_count>0) Then
		        fen_board=fen_board + AVW_util.nth_digit(blank_count)
		        blank_count=0
		      End If
		      fen_board=fen_board+ch
		    End If
		    If(BitAnd(offset+1,7)=0) Then
		      If(blank_count>0) Then
		        fen_board=fen_board + AVW_util.nth_digit(blank_count)
		        blank_count=0
		      End If
		      fen_board=fen_board+"/"
		    End
		  Next offset
		  fen_board=fen_board.left(fen_board.length-1)
		  fen_board=fen_board+" "+jboard.color_on_move.Lowercase+" "
		  Var castle_rights As Text=""
		  If jboard.castle_kingside_white > 0 Then
		    castle_rights=castle_rights+"K"
		  End If
		  If jboard.castle_queenside_white > 0 Then
		    castle_rights=castle_rights+"Q"
		  End If
		  If jboard.castle_kingside_black> 0 Then
		    castle_rights=castle_rights+"k"
		  End If
		  If jboard.castle_queenside_black > 0 Then
		    castle_rights=castle_rights+"q"
		  End If
		  If castle_rights.length<1 Then
		    castle_rights="-"
		  End If
		  fen_board=fen_board+castle_rights+" "
		  Var enpassant As Text="-"
		  If jboard.double_push> 0 Then
		    enpassant=AVW_util.nth_digit(jboard.double_push)
		  End If
		  Var space As Text=AVW_util.to_text(" ")
		  fen_board=fen_board+enpassant+space+jboard.move_number.totext+space
		  fen_board=fen_board+(Floor(jboard.move_number/2).totext)
		  Var find_move As String="position fen """+fen_board+""""
		  set_current_game(agame)
		  chess_shell.send_line(find_move.ToText)
		  Var move_time_string As String=app.settings.get_string("uci_think_time_ms")
		  chess_shell.send_line("go move time "+move_time_string.ToText)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub recieve_L1(a_dg As ICC_Datagram)
		  var dg_name_text as text = xcn_map.get_datagram_name(a_dg.nums(0))
		  print_dg("L1",dg_name_text,a_dg)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function recieve_L2(a_dg as ICC_Datagram) As boolean
		  Var dgram_num As Integer = a_dg.nums(0)
		  If Super.recieve_L2(a_dg) Then
		    Return True
		  End If
		  print_dg("UNHANDLED L2",dg_map.get_datagram_name(dgram_num),a_dg)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function recieve_L2_jboard(myj as ICC_DG_data_jboard) As Boolean
		  ignore_boolean(Super.recieve_L2_jboard(myj))
		  Var myd As ICC_DG_data_game_unified=games.find_game(myj.game_num)
		  myd.set_jboard(myj)
		  games.store_game(myj.game_num,myd)
		  pick_a_move
		  Return True
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function recieve_L2_match(adat as ICC_DG_data_match) As boolean
		  ignore_boolean(Super.recieve_L2_match(adat))
		  Var games_going_on As Integer=games.count_games_being_played
		  if games_going_on >= MAX_GAMES then
		    var mesg As Text="Sorry im full, already playing "+games_going_on.ToText+" games."
		    tell(adat.challenger_username,mesg)
		    Return True
		  end if
		  if games_going_on=0 then
		    send_line("+simul "+adat.challenger_username)
		    send_line("startsimul")
		  else
		    send_line("accept "+adat.challenger_username)
		  End If
		  Return True
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function recieve_L2_my_game_result(myr as ICC_DG_data_my_game_result) As Boolean
		  ignore_boolean(Super.recieve_L2_my_game_result(myr))
		  games.delete(myr.game_num)
		  If current_game=Nil Then
		    Return True
		  End If
		  If current_game.get_game_started.game_num <> myr.game_num Then
		    Return True
		  End If
		  clear_current_game
		  Return True
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function recieve_L2_my_game_started(myg AS ICC_DG_data_my_game_started) As boolean
		  ignore_boolean(Super.recieve_L2_my_game_started(myg))
		  Var myd As ICC_DG_data_game_unified=New ICC_DG_data_game_unified
		  myd.set_game_started(myg)
		  rem synthisize the corrent relation to this game as it won't
		  rem be sent by the chess server because ... no clue
		  Var myrel As ICC_DG_data_game_relation=New ICC_DG_data_game_relation
		  myrel.game_num=myg.game_num
		  Var my_color As Text="W"
		  If myg.black_username = Self.user_name Then
		    my_color="B"
		  End If
		  myrel.relation="S"+my_color
		  myd.set_game_relation(myrel)
		  games.store_game(myg.game_num,myd)
		  Return True
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function recieve_L2_my_relation_to_game(agr as ICC_DG_data_game_relation) As boolean
		  // Calling the overridden superclass method.
		  AVW_util.ignore_boolean(Super.recieve_L2_my_relation_to_game(agr))
		  Var myd As ICC_DG_data_game_unified=games.find_game(agr.game_num)
		  myd.set_game_relation(agr)
		  games.store_game(agr.game_num,myd)
		  Return True
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function recieve_L2_personal_tell(from as text, title as text, mesg as text, tell_type as integer) As boolean
		  If Super.recieve_L2_personal_tell(from,title,mesg,tell_type) Then
		    Return True
		  End If
		  Var atxt As Text = AVW_util.to_text("recieved L2 personal_tell from=")+from
		  atxt=atxt+AVW_util.to_text(" mesg=")+mesg
		  atxt=atxt+AVW_util.to_text(" title=")+title
		  atxt=atxt+AVW_util.to_text(" tell_type=")+tell_type.ToText
		  debug_print(atxt)
		  Return True
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function recieve_L2_who_am_i(handle as text, titles as text) As boolean
		  Return Super.recieve_L2_who_am_i(handle,titles)
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub recieve_self_tell(title as string, mesg as string, tell_type as integer)
		  rem recieve a tell to myself used for keepalive
		  #Pragma unused tell_type
		  #Pragma unused title
		  If(mesg = "keep_alive") Then
		    got_keep_alive
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function recieve_text(atxt as text) As boolean
		  if not logged_in then
		    send_login
		    logged_in = true
		  end if
		  debug_print("received text outside a DG ["+atxt+"]")
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub send_line(astr as string)
		  iccnet.Write(astr+Chr(10))
		  If app.settings.get_integer("debug_data_to_icc")>0 Then
		    app.outs("icc>"+astr)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub send_login()
		  send_line("level1=1")
		  send_line("level2settings="+login_L2_settings)
		  rem send_line("g")
		  send_line(app.settings.get_string("user"))
		  send_line(app.settings.get_string("password"))
		  send_line(app.settings.get_string("chess_startup"))
		  
		  rem may need to be TD to set buffers
		  rem send_line("set tcp_input_size 60000")
		  rem send_line("set tcp_output_size 60000")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub set_current_game(agame as ICC_DG_data_game_unified)
		  current_game=agame
		  current_game_timeout=System.Ticks+60
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub shutdown()
		  // Calling the overridden superclass method.
		  Super.shutdown()
		  user_name=""
		  '
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub startup()
		  // Calling the overridden superclass method.
		  Super.startup
		  
		  setup_L2(ICC_DG.DG_WHO_AM_I)
		  // setup_L2(ICC_DG.DG_CHANNEL_TELL)
		  setup_L2(ICC_DG.DG_PERSONAL_TELL)
		  // setup_L2(ICC_DG.DG_SHOUT)
		  setup_L2(ICC_DG.DG_MY_GAME_STARTED)
		  setup_L2(ICC_DG.DG_MY_GAME_RESULT)
		  setup_L2(ICC_DG.DG_MY_RELATION_TO_GAME)
		  setup_L2(ICC_DG.DG_JBOARD)
		  setup_L2(ICC_DG.DG_MATCH)
		  // setup_L2(ICC_DG.DG_MSEC)
		  setup_L2(ICC_DG.DG_ILLEGAL_MOVE)
		  setup_L2(ICC_DG.DG_OFFERS_IN_MY_GAME)
		  
		  make_connection
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub start_uci_bot()
		  rem chess_shell.execute("/home/wohl/node_modules/stockfish/stockfishjs")
		  Var uci_program As String=app.settings.get_string("uci_program")
		  Var uci_argument As String=app.settings.get_string("uci_argument")
		  chess_shell.execute(uci_program,uci_argument)
		  If Not chess_shell.IsRunning Then
		    app.fatal_error("execute engine failed, code="+(chess_shell.ExitCode.ToString))
		  End
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub tell(username as text, sendme as text)
		  send_line("/tell "+username+" "+sendme)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub timeout_current_game()
		  If current_game_timeout=0 Then
		    Return
		  End If
		  If System.Ticks > current_game_timeout Then
		    app.warning("timeout current_game")
		    clear_current_game
		  End If
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		chess_shell As uci_shell
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected current_game As ICC_DG_data_game_unified
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected current_game_timeout As Integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected games As table_of_games
	#tag EndProperty

	#tag Property, Flags = &h0
		icc_net As ICC_Net
	#tag EndProperty


	#tag Constant, Name = MAX_GAMES, Type = Double, Dynamic = False, Default = \"20", Scope = Protected
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="update_next_keep_alive_ticks_time"
			Visible=false
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="login_L2_settings"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="logged_in"
			Visible=false
			Group="Behavior"
			InitialValue="false"
			Type="Boolean"
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
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
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
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
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
