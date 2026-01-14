Name:           dcc
Version:        2.3.169
<<<<<<< HEAD
Release:        0%{?dist}
=======
Release:        1%{?dist}
>>>>>>> cc37894 (Adding dcc RPMS building scripts.)
Summary:        Distributed Checksum Clearinghouses
License:        https://www.dcc-servers.net/dcc/LICENSE
URL:            https://www.dcc-servers.net/dcc/source/
Source0:        %{name}.tar.Z
BuildRequires:  make gcc

%description
The Distributed Checksum Clearinghouses or DCC is an anti-spam content filter that runs on a variety of operating systems.

%prep
%setup -q

%configure --with-installroot=%{buildroot} --bindir=/usr/local/bin --homedir=/var/dcc --libexecdir=/var/dcc/libexec

%build
make %{?_smp_mflags}

%install
make install DESTDIR=%{buildroot}

%files
/var/dcc/cgi-bin
/var/dcc/libexec
/usr/local/bin
%config /var/dcc/dcc_conf
%config /var/dcc/flod
%config /var/dcc/grey_flod
%config /var/dcc/grey_whitelist
%config /var/dcc/ids
%config /var/dcc/log
%config /var/dcc/map
%config /var/dcc/map.txt
%config /var/dcc/whiteclnt
%config /var/dcc/whitecommon
%config /var/dcc/whitelist

%package dcc-debug
Summary:        Distributed Checksum Clearinghouses debug information
%description dcc-debug
The Distributed Checksum Clearinghouses or DCC is an anti-spam content filter that runs on a variety of operating systems.
This package contains debug information.
%files  dcc-debug
/usr/lib/debug/var/dcc/libexec/

%package dcc-man
Summary:        Distributed Checksum Clearinghouses man pages
%description dcc-man
The Distributed Checksum Clearinghouses or DCC is an anti-spam content filter that runs on a variety of operating systems.
This package contains man pages.
%files dcc-man
/usr/share/man

%changelog
<<<<<<< HEAD
* Fri Jan 16 2026 David Hill <dhill@redhat.com> - 2.3.169-0
=======
* Tue Jan 13 2026 David Hill <dhill@redhat.com> - 2.3.169-1
>>>>>>> cc37894 (Adding dcc RPMS building scripts.)
- Initial release
