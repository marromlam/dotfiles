globals = {
    "vim",
    "mrl",
    "map",
}

-- Ignore: unused variables/arguments, line too long, shadowing, value overwritten
ignore = {
    "211", -- unused variable
    "212", -- unused argument
    "213", -- unused loop variable
    "311", -- value assigned to variable is overwritten
    "312", -- value of field is overwritten
    "411", -- redefining a local variable
    "412", -- redefining an argument
    "421", -- shadowing a local variable
    "422", -- shadowing an argument
    "431", -- shadowing an upvalue
    "432", -- shadowing an upvalue argument
    "631", -- line is too long
}
