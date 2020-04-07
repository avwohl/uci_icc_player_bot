#tag Class
Protected Class player_app
Inherits ConsoleApplication
	#tag Event
		Function Run(args() as String) As Integer
		  Try
		    app_startup(args(1))
		    main_loop
		  Catch e As RuntimeException
		    app.fatal_error("fatal:"+e.Message)
		  End Try
		End Function
	#tag EndEvent


	#tag Method, Flags = &h1
		Protected Sub app_startup(arg as string)
		  settings=New AVW_settings(New AVW_settings_printer)
		  // add all the known settings here
		  // if a setting in this list is missing it will throw an error in the check
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
		  
		  settings.read_file(arg)
		  // report missing settings now at startup
		  // rather than much later while running
		  settings.check
		  settings.outs
		  
		  keep_going=True
		  hub=New player_hub
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub fatal_error(mesg as string)
		  outs(mesg)
		  keep_going=False
		  Quit
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function get_keep_going() As boolean
		  return keep_going
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub main_loop()
		  While get_keep_going
		    hub.handle_timeouts
		    DoEvents(1)
		  Wend
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub outs(sendme as string)
		  Print(sendme)
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
		settings As AVW_settings
	#tag EndProperty


	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass
