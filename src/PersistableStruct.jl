module PersistableStruct

using ExtendableStruct: Extendable


abstract type Persistable <: InitableLoadable end

# TODO if it is possible do a way to make this work.
# @persist obj extend!(obj,c) load_data!(obj)

const LOADED = true
const MISSING = false
load_disk!(obj::T)                     where T <: Persistable = return 0<length((files=list_files(obj);)) ? JLD2.load("$(largest(files))", "cached") : nothing
save_disk(obj::T, needclean=true)      where T <: Persistable = (needclean && clean_files(list_files(obj)); JLD2.save(unique_filename(obj), "cached",obj); obj)
save_disk_SAFE(obj::T, needclean=true) where T <: Persistable = (needclean && clean_files(excluded_best(list_files(obj))); JLD2.save(unique_filename(obj), "cached",obj); obj)


# Helper functions
list_files(obj::T)          where T <: Persistable = glob(glob_pattern(obj), folder(obj))
TOP1_idx(files::Vector{String})                    = argmax(score.(parse_args.(parse_filename.(files))))
excluded_best(files::Vector{String})               = (top_idx = TOP1_idx(files); [files[i] for i in 1:length(files) if i !==top_idx])  # IF WE would like to be VERY safe... then we can keep the last 2 version!
largest(files::Vector{String})                     = files[TOP1_idx(files)]


# Utils
strip_jld2(fname::String)                          = fname[1:end-5]
clean_files(files::Vector{String})                 = rm_if_exist.(files)
rm_if_exist(fname::String)                         = isfile(fname) && rm(fname)
mkfolder_if_not_exist(fname::String)               = for dir in split(fname, "/")
	dir == "." && continue
	isdir(dir) && mkdir(dir)
end



############ TO REDEFINE!
# The directory you want the object to persist.
folder(obj::T)              where T <: Persistable = mkfolder_if_not_exist("./data")
# The glob pattern that finds the files (You can use asterix to match custom fields)
glob_pattern(obj::T)        where T <: Persistable = "*.jld2" # throw("Unimplemented... So basically to get the files list it is advised for you to build this.") #"$(T)_$(obj.config)_*_*"*".jld2"
# The unqiue filename for your 
unique_filename(obj::T    ) where T <: Persistable = "$(T)_$(obj.config)_$(obj.fr)_$(obj.to).jld2" 
# Get config arguments
parse_filename(fname::String)                      = split(strip_jld2(fname),"_")
# Convert arguments to value
parse_args(args...)                                = ((tipe, config, fr, to = args); return String(tipe), String(config), parse(Int,fr), parse(Int,to))
# Score your files to find the best that should be kept
score(data)                                        = begin tipe, config, fr, to = data...; return to - fr; end


end # module PersistableStruct
