%define tbname         NVIDIA-Linux-x86_64
%ifarch aarch64
%define tbname         NVIDIA-Linux-aarch64
%endif
%define dirsuffix custom

%define nvidia_ml_sover 1

%ifarch %ix86
%define subd ./32
%else
%define subd ./
%endif

Name: libnvidia-ml1
Version: 470.74
Release: openEuler

Source0: null
Source201: http://http.download.nvidia.com/XFree86/Linux-x86_64/%version/%tbname-%version.run
Source202: http://http.download.nvidia.com/XFree86/Linux-x86_64/%version/%tbname-%version.run

ExclusiveArch: %ix86 x86_64 aarch64


Group: System/Kernel and hardware
Summary: NVIDIA drivers and OpenGL libraries for XOrg X-server
Url: http://www.nvidia.com
License: NVIDIA
%description
Sources for libnvidia-ml.so

%package -n libnvidia-ml
Group: System/Libraries
Summary: nvidia library
Provides: libnvidia-ml = %version-%release
%description -n libnvidia-ml
nvidia library

%prep
%setup -T -c -n %tbname-%version-%dirsuffix
rm -rf %_builddir/%tbname-%version-%dirsuffix
cd %_builddir
%ifarch aarch64
sh %SOURCE202 -x --add-this-kernel
%else
sh %SOURCE201 -x --add-this-kernel
%endif
cd %tbname-%version-%dirsuffix

pushd kernel
rm -rf precompiled
popd

%build

%install
# install libraries
mkdir -p %buildroot/%_libdir/
install -m 0644 %subd/libnvidia-ml.so.%version %buildroot/%_libdir/

%files -n libnvidia-ml
%_libdir/libnvidia-ml.so.%version
%_libdir/libnvidia-ml.so.%{nvidia_ml_sover}

