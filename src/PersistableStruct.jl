module PersistableStruct

using ExtendableStruct: Extendable


abstract type Persistable <: InitableLoadable end


# Core
# persisting(obj) = (load_disk(obj), obj)
# load_disk(obj) = if 0<length((files=ls_files(obj);))
# 	c=JLD2.load("$(largest(files))", "cached")
# 	need_more_data(obj,c) && return save(merge(data_before(obj,c),c,data_after(c, obj)))
# 	return c
# else; return save(load_data(obj), false)
# end
const LOADED = true
const MISSING = false
load_disk!(obj::T)                     where T <: Persistable = return 0<length((files=list_files(obj);)) ? (JLD2.load("$(largest(files))", "cached"), LOADED) : (obj, MISSING)
save_disk(obj::T, needclean=true)      where T <: Persistable = (needclean && clean_files(list_files(obj)); JLD2.save(persistent_filename(obj), "cached",obj); obj)
save_disk_SAFE(obj::T, needclean=true) where T <: Persistable = (needclean && clean_files(excluded_best(list_files(obj))); JLD2.save(persistent_filename(obj), "cached",obj); obj)


# Helper functions
list_files(obj::T)          where T <: Persistable = glob(glob_pattern(obj), folder(obj))
TOP1_idx(files::Vector{String})                    = argmax(score.(parse_filename.(files)))
excluded_best(files::Vector{String})               = (top_idx = TOP1_idx(files); [files[i] for i in 1:length(files) if i !==top_idx])  # IF WE would like to be VERY safe... then we can keep the last 2 version!
largest(files::Vector{String})                     = files[TOP1_idx(files)]

# Utils
strip_jld2(fname::String)                          = fname[1:end-5]
clean_files(files::Vector{String})                 = rm_if_exist.(files)
rm_if_exist(fname::String)                         = isfile(fname) && rm(fname)


# TO REDEFINE!
folder(obj::T)              where T <: Persistable = "./"
glob_pattern(obj::T)        where T <: Persistable = "$(T)_$(obj.config)_*_*"*".jld2"
persistent_filename(obj::T) where T <: Persistable = "$(T)_$(obj.config)_$(obj.fr)_$(obj.to).jld2" 
score(data)                                        = begin tipe, config, fr, to = data...; return to - fr; end
parse_filename(fname::String)                      = begin
	throw("Todo INTERFACE method to implement to use 'Persistable': folder(), glob_pattern(), persistent_filename(), score(), parse_filename()")
	tipe, config, fr, to = split(strip_jld2(fname),"_")
	return String(tipe), String(config), parse(Int,fr), parse(Int,to)
end


end # module PersistableStruct
