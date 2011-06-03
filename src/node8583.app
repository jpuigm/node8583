{application, node8583,
	[
		{description, "TCP server"},
		{vsn, "0.1.0"},
		{modules, 	[node8583_app,
					node8583_server,
					node8583_sup]},
		{applications, [kernel, stdlib, crypto]},
		{mod, {node8583_app, []}}
	]
}.