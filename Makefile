OUT_ZIP=ubuntuCloud.zip
LNCR_EXE=ubuntuCloud.exe

DLR=curl
DLR_FLAGS=-L
BASE_URL=https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64-wsl.rootfs.tar.gz
LNCR_ZIP_URL=https://github.com/yuk7/wsldl/releases/download/20040300/icons.zip
LNCR_ZIP_EXE=Ubuntu.exe

PLANTUML_URL=http://sourceforge.net/projects/plantuml/files/plantuml.jar/download
ACROTEX_URL=http://mirrors.ctan.org/macros/latex/contrib/acrotex.zip
DRAWIO_URL=https://github.com/jgraph/drawio-desktop/releases/download/v13.3.5/draw.io-amd64-13.3.5.deb

INSTALL_PS_SCRIPT=https://raw.githubusercontent.com/binarylandscapes/ubuntuWSL/$(BRANCH)/install.ps1
FEATURE_PS_SCRIPT=https://raw.githubusercontent.com/binarylandscapes/ubuntuWSL/$(BRANCH)/addWSLfeature.ps1

all: $(OUT_ZIP)

zip: $(OUT_ZIP)
$(OUT_ZIP): ziproot
	@echo -e '\e[1;31mBuilding $(OUT_ZIP)\e[m'
	cd ziproot; bsdtar -a -cf ../$(OUT_ZIP) *

ziproot: Launcher.exe rootfs.tar.gz ps_scripts
	@echo -e '\e[1;31mBuilding ziproot...\e[m'
	mkdir ziproot
	cp Launcher.exe ziproot/${LNCR_EXE}
	cp rootfs.tar.gz ziproot/
	cp install.ps1 ziproot/
	cp addWSLfeature.ps1 ziproot/

ps_scripts:
	$(DLR) $(DLR_FLAGS) $(INSTALL_PS_SCRIPT) -o install.ps1
	$(DLR) $(DLR_FLAGS) $(FEATURE_PS_SCRIPT) -o addWSLfeature.ps1

exe: Launcher.exe
Launcher.exe: icons.zip
	@echo -e '\e[1;31mExtracting Launcher.exe...\e[m'
	bsdtar -xvf icons.zip $(LNCR_ZIP_EXE)
	mv $(LNCR_ZIP_EXE) Launcher.exe

icons.zip:
	@echo -e '\e[1;31mDownloading icons.zip...\e[m'
	$(DLR) $(DLR_FLAGS) $(LNCR_ZIP_URL) -o icons.zip

rootfs.tar.gz: rootfs
	@echo -e '\e[1;31mBuilding rootfs.tar.gz...\e[m'
	cd rootfs; sudo tar -zcpf ../rootfs.tar.gz `sudo ls`
	sudo chown `id -un` rootfs.tar.gz

rootfs: base.tar.gz profile
	@echo -e '\e[1;31mBuilding rootfs...\e[m'
	mkdir rootfs
	sudo tar -zxpf base.tar.gz -C rootfs
	sudo mkdir rootfs/run/systemd
	sudo mkdir rootfs/run/systemd/resolve 
	sudo cp -f /etc/resolv.conf rootfs/run/systemd/resolve/stub-resolv.conf
	sudo cp -f profile rootfs/etc/profile
	sudo chroot rootfs /bin/apt update -y
	sudo chroot rootfs /bin/apt upgrade -y
	sudo chroot rootfs /bin/apt upgrade -y \
		bash \
		bash-completion \
		coreutils \
		wget \
		curl \
		zip \
		unzip \
		git-lfs \
		subversion \
		genisoimage \
		neofetch \
		openssh-client \
		nano \
		openssl
	sudo chroot rootfs /bin/apt upgrade -y \
		gcc \
		libgmp10 \
		libffi7 \
		musl-dev \
		sed \
		zlib1g-dev \
		libjpeg-dev \
		dvipng \
		ghostscript \
		graphviz \
		xvfb \
		ruby
	sudo chroot rootfs /bin/apt upgrade -y \
		python3 \
		python3-pip \
		python3-dev \
		cython \
		python3-numpy \
		python3-numpy-dev
	sudo chroot rootfs /bin/apt upgrade -y \
		ttf-dejavu \
		texlive-latex-recommended \
		texlive-latex-extra
	sudo chroot rootfs /bin/apt upgrade -y \
		libicu66 \
		libkrb5-3 \
		libsecret-common \
		gnome-keyring \
		desktop-file-utils
	sudo chroot rootfs /bin/apt upgrade -y \
		java-common \
		fprintd
	sudo chroot rootfs /bin/apt upgrade -y \
		libfprint-2-2:amd64 \
		libpam-fprintd:amd64
	sudo -H chroot rootfs /usr/bin/python3 -m pip install --upgrade \
		pip \
		wheel
	sudo -H chroot rootfs /usr/bin/python3 -m pip install --upgrade \
		sphinx \
		sphinx-autobuild \
		sphinx-jinja \
		netaddr \
		gitpython \
		seqdiag \
		sphinxcontrib-seqdiag \
		nwdiag \
		sphinxcontrib-nwdiag \
		blockdiag \
		sphinxcontrib-blockdiag \
		actdiag \
		sphinxcontrib-actdiag \
		sphinx-git \
		sphinx_rtd_theme \
		plantuml \
		sphinxcontrib-plantuml \
		reportlab \
		colorama \
		xlsxwriter \
		pandas \
		vscod \
		tablib \
		ciscoconfparse \
		nety \
		sphinxcontrib-jupyter \
		sphinxcontrib_ansibleautodoc \
		sphinxcontrib-confluencebuilder \
		pyyaml \
		yamlreader \
		sphinxcontrib-drawio \
		sphinxcontrib-drawio-html \
		sphinx-markdown-builder \
		sphinxcontrib-fulltoc
	sudo chroot rootfs \
		/usr/bin/$(DLR) $(DLR_FLAGS) $(PLANTUML_URL) \
		-o /usr/local/plantuml.jar
	sudo chroot rootfs \
		/usr/bin/$(DLR) $(DLR_FLAGS) $(ACROTEX_URL) \
		-o /tmp/acrotex.zip
	sudo chroot rootfs /usr/bin/unzip \
		/tmp/acrotex.zip -d /usr/share/texlive/texmf-dist/tex/latex/
	sudo chroot rootfs /usr/bin/mktexlsr
	sudo chroot rootfs /bin/rm -f \
		/tmp/acrotex.zip
	sudo chroot rootfs \
		/usr/bin/$(DLR) $(DLR_FLAGS) $(DRAWIO_URL) \
		-o /tmp/draw.io.deb
	sudo chroot rootfs /bin/apt upgrade -y \
		/tmp/draw.io.deb
	sudo chroot rootfs /bin/rm -f \
		/tmp/draw.io.deb
	sudo chroot rootfs /bin/rm -rf \
		/run/systemd/resolve
	sudo chroot rootfs /usr/bin/gem install \
		travis --no-document
	echo "# This file was automatically generated by WSL. To stop automatic generation of this file, remove this line." | sudo tee rootfs/etc/resolv.conf
	sudo chmod +x rootfs

base.tar.gz:
	@echo -e '\e[1;31mDownloading base.tar.gz...\e[m'
	$(DLR) $(DLR_FLAGS) $(BASE_URL) -o base.tar.gz

clean:
	@echo -e '\e[1;31mCleaning files...\e[m'
	-rm ${OUT_ZIP}
	-rm -r ziproot
	-rm Launcher.exe
	-rm icons.zip
	-rm rootfs.tar.gz
	-sudo rm -r rootfs
	-rm base.tar.gz
	-rm install.ps1
	-rm addWSLfeature.ps1
