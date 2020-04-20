#tag Class
Protected Class player_app
Inherits ConsoleApplication
Implements AVW_util.outputer
	#tag Event
		Function Run(args() as String) As Integer
		  Try
		    app_startup(args(1))
		    main_loop
		  Catch e As RuntimeException
		    Print("fatal:"+e.Message)
		    Quit
		  End Try
		End Function
	#tag EndEvent


	#tag Method, Flags = &h1
		Protected Sub app_startup(arg as string)
		  Var my_build As DateTIme
		  my_build=App.BuildDate
		  outs("*** uci_icc_player_bot build on "+my_build.ToString)
		  outs("version "+app.Version)
		  
		  settings=New AVW_settings_module.AVW_settings
		  // add all the known settings here
		  // if a setting in this list is missing it will throw an error in the check
		  settings.define("event_sleep_ms")
		  settings.define("ask_icc_every_seconds")
		  settings.define("chess_startup")
		  settings.define("debug_data_from_uci")
		  settings.define("debug_data_to_icc")
		  settings.define("debug_data_to_uci")
		  settings.define("debug_print")
		  settings.define("die_if_no_icc_response_seconds")
		  settings.define("icc_hostname")
		  settings.define("icc_port")
		  settings.define("password")
		  settings.define("uci_argument")
		  settings.define("uci_program")
		  settings.define("uci_startup")
		  settings.define("uci_think_time_ms")
		  settings.define("user")
		  
		  settings.read_file(app,arg)
		  // report missing settings now at startup
		  // rather than much later while running
		  settings.check
		  
		  Var settings_printer As New AVW_settings_print_each_iterator(Self)
		  settings.for_each_setting(settings_printer)
		  
		  keep_going=True
		  hub=New player_hub
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function get_keep_going() As boolean
		  return keep_going
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub main_loop()
		  Var sleep_time As Integer=app.settings.get_integer("event_sleep_ms")
		  While get_keep_going
		    hub.handle_timeouts
		    DoEvents(sleep_time)
		  Wend
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub outs(outme as string)
		  // Part of the AVW_util.outputer interface.
		  
		  Print(outme)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub warning(mesg as string)
		  outs(mesg)
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h1
		Protected hub As player_hub
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected keep_going As boolean = true
	#tag EndProperty

	#tag Property, Flags = &h0
		settings As AVW_settings_module.AVW_settings
	#tag EndProperty


	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass
