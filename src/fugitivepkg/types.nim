from tables import Table

type
  Arguments* = seq[string]
  Options* = Table[string, string]
  Input* = tuple[args: Arguments, opts: Options]
