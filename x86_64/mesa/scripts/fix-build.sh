#!/bin/sh

sed -i 's/-pthread/-lpthread/'                  $1/build.ninja
sed -i 's/-DHAVE_DL_ITERATE_PHDR//'             $1/build.ninja
sed -i 's/-DHAVE_DLFCN_H//'                     $1/build.ninja
sed -i 's/-DHAVE_DLADDR//'                      $1/build.ninja
sed -i 's/-DHAVE_MEMFD_CREATE//'                $1/build.ninja
sed -i 's/-DHAVE_PROGRAM_INVOCATION_NAME//'     $1/build.ninja
sed -i 's/-DHAS_SCHED_GETAFFINITY//'            $1/build.ninja