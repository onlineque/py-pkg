#
# Copyright (c) 2013 Marin Atanasov Nikolov <dnaeon@gmail.com>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer
#    in this position and unchanged.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR(S) ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
# OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE AUTHOR(S) BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
# NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

cdef class PkgShlib(object):
    cdef c_pkg.pkg_shlib *_shlib

    def __cinit__(self):
        self._shlib = NULL

    cdef _init(self, c_pkg.pkg_shlib *shlib):
        self._shlib = shlib

    def __dealloc__(self):
        pass

    def __str__(self):
        return '%s' % self.name()
        
    cpdef name(self):
        return c_pkg.pkg_shlib_name(shlib=self._shlib)

cdef class PkgShlibsRequiredIter(object):
    cdef c_pkg.pkg *_pkg
    cdef c_pkg.pkg_shlib *_shlib

    def __cinit__(self):
        self._pkg = NULL
        self._shlib = NULL

    cdef _init(self, c_pkg.pkg *pkg):
        self._pkg = pkg

    def __dealloc__(self):
        pass

    def __iter__(self):
        return self

    def __len__(self):
        cdef unsigned i = 0

        for d in self:
            i += 1

        return i

    def __contains__(self, name):
        for s in self:
            if s.name() == name:
                return True

        return False

    def __next__(self):
        result = c_pkg.pkg_shlibs_required(pkg=self._pkg, shlib=&self._shlib)

        if result != c_pkg.EPKG_OK:
            raise StopIteration

        pkg_shlib_obj = PkgShlib()
        pkg_shlib_obj._init(self._shlib)

        return pkg_shlib_obj

cdef class PkgShlibsProvidedIter(PkgShlibsRequiredIter):

    def __next__(self):
        result = c_pkg.pkg_shlibs_provided(pkg=self._pkg, shlib=&self._shlib)

        if result != c_pkg.EPKG_OK:
            raise StopIteration
        
        pkg_shlib_obj = PkgShlib()
        pkg_shlib_obj._init(self._shlib)
            
        return pkg_shlib_obj
