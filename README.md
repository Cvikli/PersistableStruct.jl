# PersistableStruct.jl
Persistable data interface

In short, this pkg is to create the simples interface to make your struct persistable. :)



## Example
`YOUR_STRUCT` has to be `InitableLoadable`. So basically has to be possible to be `inited` by specifying the config and then `loadable` based on your struct's config. So the struct holds its `data` & `config` simultaneously.
You have to overload for `YOUR_STRUCT` these functions:
```julia
# The directory you want the object to persist.
folder(obj::T)              where T <: Persistable = "./"
# The glob pattern that finds the files (You can use asterix to match custom fields)
glob_pattern(obj::T)        where T <: Persistable = "$(T)_$(obj.config)_*_*"*".jld2"
# The unqiue filename for your 
unique_filename(obj::T    ) where T <: Persistable = "$(T)_$(obj.config)_$(obj.fr)_$(obj.to).jld2" 
# Get config arguments
parse_filename(fname::String)                      = split(strip_jld2(fname),"_")
# Convert arguments to value
parse_args(args...)                                = ((tipe, config, fr, to = args); return String(tipe), String(config), parse(Int,fr), parse(Int,to))
# Score your files to find the best that should be kept
score(data)                                        = begin tipe, config, fr, to = data...; return to - fr; end
```

Then you can use this:
```julia
obj = init(YOUR_STRUCT, args...)
c, is_loaded = load_disk(obj)
save_disk(is_loaded ? extend!(obj,c) : load_data!(obj), is_loaded)
```

#### Features
 - `load_disk` / `save_disk` / `save_disk_SAFE` (leaving 2 version on the disk from the same)
 - we clean the data that is already not having the most accurate information
 - Basic things already overloaded, so you have to only overload the really custom objects.

