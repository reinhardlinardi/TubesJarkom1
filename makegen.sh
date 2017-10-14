#!/bin/bash

if [[ -d src ]] # if src exists and is a directory
then
	printf "Collecting information from source files ...\n"

	src_folders=$(find src -type d | grep -o -P '(?<=src/).+') # find all subdirectories of src

	touch Makefile # assure Makefile exists
	rm Makefile # remove Makefile

	all_header=$(find src -type f -name '*.h') # find all header files
	all_src=$(find src -type f -name '*.cpp') # find all implementation files

	object_files="" # list of all object files
	cnt=0 # counter
	first_obj_file=true

	for files in $all_src # search for all cpp
	do
		extension=$(printf "$files" | grep -o -P '\..+$') # get file extension
		filename=$(basename $files $extension) # get filename
		filepath=$(printf "$files" | grep -o -P ".+(?=$filename$extension)") # get file path
		
		if [[ $extension != ".h" ]] # for every .cpp files
		then
			filepath_in_src=$(printf "$filepath" | grep -o -P '(?<=src/).+') # get file path relative to src
			
			if [[ $first_obj_file == true ]]
			then
				first_obj_file=false
			else
				object_files+=" "
			fi
			
			if [[ $filename != "client" ]] && [[ $filename != "server" ]] # exclude server and client from object files
			then
				object_files+="$filepath_in_src$filename.o" # object files
			fi
			
			includes=$(cat "$files" | grep -o -P '#include *".+"') # get all #include
			dependencies=$(printf "$includes" | grep -o -P '(?<=")[^"]+') # get all dependencies
			
			((cnt++))
			rules[cnt]="$filepath_in_src$filename.o: $files" # add object code name
			files[cnt]=$files
			
			for dependency in $dependencies
			do
				# Check all dependencies
				dependency_name=$(basename $dependency ".h") # get dependency name only
				dependency_path=$(printf "$all_header" | grep -o -P ".+(?=(?<=/)$dependency_name\.h)") # get dependency path
				
				rules[cnt]+=" $dependency_path$dependency_name.h" # add dependency name
			done
			
			if [[ ${rules[cnt]} == "" ]]
			then
				((cnt--))
			fi
		fi
	done

	printf "Generating Makefile ...\n"

	# Write linking executable rule

	printf "sendfile: client.o $object_files\n" >> Makefile
	printf "	@echo \"Linking sendfile ...\"\n" >> Makefile
	printf "	@g++ client.o $object_files -o sendfile\n\n" >> Makefile

	printf "recvfile: server.o $object_files\n" >> Makefile
	printf "	@echo \"Linking recvfile ...\"\n" >> Makefile
	printf "	@g++ server.o $object_files -o recvfile\n\n" >> Makefile

	# Write compiling source file rule

	for i in $(seq 1 $cnt)
	do
		current_obj_path=$(printf "${rules[i]}" | grep -o -P '^[^:]+')
		src_name=$(printf "${rules[i]}" | grep -o -P '^[^\.]+')

		printf "${rules[i]}\n" >> Makefile
		printf "	@echo \"Compiling $src_name.cpp ...\"\n" >> Makefile
		printf "	@g++ -c ${files[i]} -o $current_obj_path $@\n\n" >> Makefile
	done

	# Write clean rule

	printf ".PHONY: clean all\n\n" >> Makefile

	printf "clean:\n" >> Makefile
	printf "	@echo \"Removing object files ...\"\n" >> Makefile
	printf "	@rm -rf *.o\n" >> Makefile
	
	printf "\n	@echo \"Removing executable ...\"\n" >> Makefile
	printf "	@rm -rf sendfile recvfile\n\n" >> Makefile

	printf "all : sendfile recvfile" >> Makefile
else
	printf "Cannot find \"src\" folder. Please put your source files (except drivers) in \"src\" folder.\n"
fi
