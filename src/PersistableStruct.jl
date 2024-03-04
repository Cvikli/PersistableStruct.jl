module PersistableStruct

using JLD2
using Glob

using Unimplemented

abstract type Persistable end

# TODO if it is possible do a way to make this work.
# @persist obj extend!(obj,c) load_data!(obj)

load_disk(file_name::String)           = return JLD2.load(file_name, "cached") 
load_disk(obj)                         = return 0<length((files=list_files(obj);)) ? JLD2.load(largest(files), "cached") : nothing
save_disk(obj, needclean=true)         = (needclean && clean_files(list_files(obj));                JLD2.save(sure_folder(obj) * unique_filename(obj), "cached", obj); obj)
save_disk_SAFE(obj, needclean=true)    = (needclean && clean_files(excluded_best(list_files(obj))); JLD2.save(sure_folder(obj) * unique_filename(obj), "cached", obj); obj)



# Helper functions
list_files(obj)                        = glob(glob_pattern(obj), sure_folder(obj))
TOP1_idx(files::Vector{String})        = argmax(score.(parse_args.(parse_filename.(files))))
excluded_best(files::Vector{String})   = (top_idx = TOP1_idx(files); [files[i] for i in 1:length(files) if i !==top_idx])  # IF WE would like to be VERY safe... then we can keep the last 2 version!
largest(files::Vector{String})         = files[TOP1_idx(files)]
endwithslash(dir)                      = ((dir[end] !== '/' && println("we add a slash to the end of the folder: ", dir ," appended: '/'")); return dir[end] == '/' ? dir : dir*"/")
sure_folder(obj)                       = (mkfolder_if_not_exist((foldname=endwithslash(folder(obj));)); return foldname)


# Utils
strip_jld2(fname::String)              = fname[1:end-5]
clean_files(files::Vector{String})     = rm_if_exist.(files)
rm_if_exist(fname::String)             = isfile(fname) && rm(fname)
mkfolder_if_not_exist(fname::String)   = begin
	whole_dir = ""
	for dir in split(fname, "/")
		whole_dir *= dir * "/"
		dir in [".", ""] && continue
		!isdir(whole_dir) && mkdir(whole_dir)
	end
end



############ TO REDEFINE!
# The directory you want the object to persist.
folder(obj)                     = "./data/"
# The glob pattern that finds the files (You can use asterix to match custom fields)
glob_pattern(obj)               = "*.jld2" # This is only for ExtendablePersistable object... throw("Unimplemented... So basically to get the files list it is advised for you to build this.") #"$(T)_$(obj.config)_*_*"*".jld2"
# Get config arguments
parse_filename(fname::String)   = split(strip_jld2(fname),"_")
# The unqiue filename for your 
@interface unique_filename(obj) # = "$(T)_$(obj.config)_$(obj.fr)_$(obj.to).jld2" 
# Convert arguments to value
@interface parse_args(::T,args...) where T  #   = ((tipe, config, fr, to) = args; return String(tipe), String(config), parse(Int,fr), parse(Int,to))
# Score your files to find the best that should be kept
@interface score(::T,data)         where T  # This is only for ExtendablePersistable object...       # = begin 
# 	(tipe, config, fr, to) = data
# 	return to - fr
# end


end # module PersistableStruct
