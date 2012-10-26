include(PVExternalProject)
include(CMakeParseArguments)

#------------------------------------------------------------------------------
# Macro to be used to register versions for any module. This makes it easier to
# consolidate versions for all modules in a single file, if needed.
macro(add_revision name)
  set(${name}_revision "${ARGN}")
endmacro()

#------------------------------------------------------------------------------
macro(add_external_project _name)
  project_check_name(${_name})
  set(cm-project ${_name})
  set(${cm-project}_DECLARED 1)

  if (build-projects)
    set (arguments)
    set (optional_depends)
    set (accumulate FALSE)
    set (project_arguments "${ARGN}") #need quotes to keep empty list items
    foreach(arg IN LISTS project_arguments)
      if ("${arg}" MATCHES "^DEPENDS_OPTIONAL$")
        set (accumulate TRUE)
      elseif ("${arg}" MATCHES "${_ep_keywords_ExternalProject_Add}")
        set (accumulate FALSE)
      elseif (accumulate)
        list(APPEND optional_depends "${arg}")
      endif()

      if (NOT accumulate)
        list(APPEND arguments "${arg}")
      endif()
    endforeach()

    foreach (op_dep ${optional_depends})
      if (${op_dep}_ENABLED)
        list (APPEND arguments DEPENDS ${op_dep})
      endif()
    endforeach()
    set(${cm-project}_ARGUMENTS "${arguments}")

    unset(arguments)
    unset(optional_depends)
    unset(accumulate)
  else()
    set(${cm-project}_DEPENDS "")
    set(${cm-project}_ARGUMENTS "")
    set(${cm-project}_NEEDED_BY "")
    set(${cm-project}_CAN_USE_SYSTEM 0)
    set (doing "")

    set (project_arguments "${ARGN}") #need quotes to keep empty list items
    foreach(arg IN LISTS project_arguments)
      if ("${arg}" MATCHES "^DEPENDS$")
        set (doing "DEPENDS")
      elseif ("${arg}" MATCHES "^DEPENDS_OPTIONAL$")
        set (doing "DEPENDS_OPTIONAL")
      elseif ("${arg}" MATCHES "${_ep_keywords_ExternalProject_Add}")
        set (doing "")
      elseif (doing STREQUAL "DEPENDS")
        list(APPEND ${cm-project}_DEPENDS "${arg}")
      elseif ((doing STREQUAL "DEPENDS_OPTIONAL") AND ENABLE_${arg})
        list(APPEND ${cm-project}_DEPENDS "${arg}")
      endif()

    endforeach()

    option(ENABLE_${cm-project} "Request to build project ${cm-project}" OFF)
    set_property(CACHE ENABLE_${cm-project} PROPERTY TYPE BOOL)
    list(APPEND CM_PROJECTS_ALL "${cm-project}")

    if (USE_SYSTEM_${cm-project})
      set(${cm-project}_DEPENDS "")
    endif()
  endif()
endmacro()

#------------------------------------------------------------------------------
# adds a dummy project to the build, which is a great way to setup a list
# of dependencies as a build option. IE dummy project that turns on all
# third party libraries
macro(add_external_dummy_project _name)
  if (build-projects)
    add_external_project(${_name} "${ARGN}")
  else()
    add_external_project(${_name} "${ARGN}")
    set(${_name}_IS_DUMMY_PROJECT TRUE CACHE INTERNAL
      "Project just used to represent a logical block of dependencies" )
  endif()
endmacro()

#------------------------------------------------------------------------------
# similar to add_external_project, except provides the user with an option to
# use-system installation of the project.
macro(add_external_project_or_use_system _name)
  if (build-projects)
    add_external_project(${_name} "${ARGN}")
  else()
    add_external_project(${_name} "${ARGN}")
    set(${_name}_CAN_USE_SYSTEM 1)

    # add an option an hide it by default. We'll expose it to the user if needed.
    option(USE_SYSTEM_${_name} "Use system ${_name}" OFF)
    set_property(CACHE USE_SYSTEM_${_name} PROPERTY TYPE INTERNAL)
  endif()
endmacro()

#------------------------------------------------------------------------------
macro(process_dependencies)
  set (CM_PROJECTS_ENABLED "")
  foreach(cm-project IN LISTS CM_PROJECTS_ALL)
    set(${cm-project}_ENABLED FALSE)
    if (ENABLE_${cm-project})
      list(APPEND CM_PROJECTS_ENABLED ${cm-project})
    endif()
  endforeach()
  list(SORT CM_PROJECTS_ENABLED) # Deterministic order.

  # Order list to satisfy dependencies. We don't include the use-system
  # libraries in the depedency walk.
  include(TopologicalSort)
  topological_sort(CM_PROJECTS_ENABLED "" _DEPENDS)

  # build information about what project needs what.
  foreach (cm-project IN LISTS CM_PROJECTS_ENABLED)
    enable_project(${cm-project} "")
    foreach (dependency IN LISTS ${cm-project}_DEPENDS)
      enable_project(${dependency} "${cm-project}")
    endforeach()
  endforeach()

  foreach (cm-project IN LISTS CM_PROJECTS_ENABLED)
    if (ENABLE_${cm-project})
      message(STATUS "Enabling ${cm-project} as requested.")
      set_property(CACHE ENABLE_${cm-project} PROPERTY TYPE BOOL)
    else()
      list(SORT ${cm-project}_NEEDED_BY)
      list(REMOVE_DUPLICATES ${cm-project}_NEEDED_BY)
      message(STATUS "Enabling ${cm-project} since needed by: ${${cm-project}_NEEDED_BY}")
      set_property(CACHE ENABLE_${cm-project} PROPERTY TYPE INTERNAL)
    endif()
  endforeach()
  message(STATUS "PROJECTS_ENABLED ${CM_PROJECTS_ENABLED}")
  set (build-projects 1)
  foreach (cm-project IN LISTS CM_PROJECTS_ENABLED)
    if (${cm-project}_CAN_USE_SYSTEM)
      # for every enabled project that can use system, expose the option to the
      # user.
      set_property(CACHE USE_SYSTEM_${cm-project} PROPERTY TYPE BOOL)
      if (USE_SYSTEM_${cm-project})
        add_external_dummy_project_internal(${cm-project})
        include(${cm-project}.use.system OPTIONAL RESULT_VARIABLE rv)
        if (rv STREQUAL "NOTFOUND")
          message(AUTHOR_WARNING "${cm-project}.use.system not found!!!")
        endif()
      else()
        include(${cm-project})
        add_external_project_internal(${cm-project} "${${cm-project}_ARGUMENTS}")
      endif()
    elseif(${cm-project}_IS_DUMMY_PROJECT)
      #this project isn't built, just used as a graph node to
      #represent a group of dependencies
      add_external_dummy_project_internal(${cm-project})
    else()
      include(${cm-project})
      add_external_project_internal(${cm-project} "${${cm-project}_ARGUMENTS}")
    endif()
  endforeach()
  unset (build-projects)
endmacro()
#------------------------------------------------------------------------------
macro(enable_project name needed-by)
  set (${name}_ENABLED TRUE CACHE INTERNAL "" FORCE)
  list (APPEND ${name}_NEEDED_BY "${needed-by}")
endmacro()

#------------------------------------------------------------------------------
# internal macro to validate project names.
macro(project_check_name _name)
  if( NOT "${_name}" MATCHES "^[a-zA-Z][a-zA-Z0-9]*$")
    message(FATAL_ERROR "Invalid project name: ${_name}")
  endif()
endmacro()

#------------------------------------------------------------------------------
macro(get_project_depends _name _prefix)
  if (NOT ${_prefix}_${_name}_done)
    set(${_prefix}_${_name}_done 1)
    foreach (dep ${${_name}_DEPENDS})
      if (NOT ${_prefix}_${dep}_done)
        list(APPEND ${_prefix}_DEPENDS ${dep})
        get_project_depends(${dep} ${_prefix})
      endif()
    endforeach()
  endif()
endmacro()

#------------------------------------------------------------------------------
function(add_external_dummy_project_internal name)
  ExternalProject_Add(${name}
  DOWNLOAD_COMMAND ""
  SOURCE_DIR ""
  UPDATE_COMMAND ""
  CONFIGURE_COMMAND ""
  BUILD_COMMAND ""
  INSTALL_COMMAND ""
  )
endfunction()

#------------------------------------------------------------------------------
function(add_external_project_internal name)
  set (cmake_params)
  foreach (flag CMAKE_BUILD_TYPE
                CMAKE_C_FLAGS_DEBUG
                CMAKE_C_FLAGS_MINSIZEREL
                CMAKE_C_FLAGS_RELEASE
                CMAKE_C_FLAGS_RELWITHDEBINFO
                CMAKE_CXX_FLAGS_DEBUG
                CMAKE_CXX_FLAGS_MINSIZEREL
                CMAKE_CXX_FLAGS_RELEASE
                CMAKE_CXX_FLAGS_RELWITHDEBINFO)
    if (flag)
      list (APPEND cmake_params -D${flag}:STRING=${${flag}})
    endif()
  endforeach()

  if (APPLE)
    list (APPEND cmake_params
      -DCMAKE_OSX_ARCHITECTURES:STRING=${CMAKE_OSX_ARCHITECTURES}
      -DCMAKE_OSX_DEPLOYMENT_TARGET:STRING=${CMAKE_OSX_DEPLOYMENT_TARGET}
      -DCMAKE_OSX_SYSROOT:PATH=${CMAKE_OSX_SYSROOT})
  endif()

  #get extra-cmake args from every dependent project, if any.
  set(arg_DEPENDS)
  get_project_depends(${name} arg)
  foreach(dependency IN LISTS arg_DEPENDS)
		get_property(args GLOBAL PROPERTY ${dependency}_CMAKE_ARGS)
    list(APPEND cmake_params ${args})
  endforeach()

#if (name STREQUAL "paraview")
#  message("${ARGN}")
#endif()

  # refer to documentation for PASS_LD_LIBRARY_PATH_FOR_BUILDS in
  # in root CMakeLists.txt.
  set (ld_library_path_argument)
  if (PASS_LD_LIBRARY_PATH_FOR_BUILDS)
    set (ld_library_path_argument
      LD_LIBRARY_PATH "${ld_library_path}")
  endif ()


  #args needs to be quoted so that empty list items aren't removed
  #if that happens options like INSTALL_COMMAND "" won't work
  set(args "${ARGN}")
  PVExternalProject_Add(${name} "${args}"
    PREFIX ${name}
    DOWNLOAD_DIR ${download_location}
    INSTALL_DIR ${install_location}

    # add url/mdf/git-repo etc. specified in versions.cmake
    ${${name}_revision}

    PROCESS_ENVIRONMENT
      LDFLAGS "${ldflags}"
      CPPFLAGS "${cppflags}"
      CXXFLAGS "${cxxflags}"
      CFLAGS "${cflags}"
# disabling this since it fails when building numpy.
#      MACOSX_DEPLOYMENT_TARGET "${CMAKE_OSX_DEPLOYMENT_TARGET}"
      ${ld_library_path_argument}
      CMAKE_PREFIX_PATH "${prefix_path}"
    CMAKE_ARGS
      -DCMAKE_INSTALL_PREFIX:PATH=${prefix_path}
      -DCMAKE_PREFIX_PATH:PATH=${prefix_path}
      -DCMAKE_C_FLAGS:STRING=${cflags}
      -DCMAKE_CXX_FLAGS:STRING=${cppflags}
      -DCMAKE_SHARED_LINKER_FLAGS:STRING=${ldflags}
      ${cmake_params}
    )

  get_property(additional_steps GLOBAL PROPERTY ${name}_STEPS)
  if (additional_steps)
     foreach (step ${additional_steps})
       get_property(step_contents GLOBAL PROPERTY ${name}-STEP-${step})
       ExternalProject_Add_Step(${name} ${step} ${step_contents})
     endforeach()
  endif()
endfunction()

macro(add_extra_cmake_args)
  if (build-projects)
    if (NOT cm-project)
      message(AUTHOR_WARNING "add_extra_cmake_args called an incorrect stage.")
      return()
    endif()
    set_property(GLOBAL APPEND PROPERTY ${cm-project}_CMAKE_ARGS ${ARGN})
  else()
    # nothing to do.
  endif()
endmacro()

macro(add_external_project_step name)
  if (build-projects)
    if (NOT cm-project)
      message(AUTHOR_WARNING "add_external_project_step called an incorrect stage.")
      return()
    endif()
    set_property(GLOBAL APPEND PROPERTY ${cm-project}_STEPS "${name}")
    set_property(GLOBAL APPEND PROPERTY ${cm-project}-STEP-${name} ${ARGN})
  else()
    # nothing to do.
  endif()
endmacro()
