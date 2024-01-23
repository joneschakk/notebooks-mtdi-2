ARG BASE_IMAGE=registry.git.rwth-aachen.de/jupyter/profiles/octave:latest
ARG BUILDER_IMAGE=registry.git.rwth-aachen.de/jupyter/profiles/dpsim:latest
FROM ${BUILDER_IMAGE} AS base

USER root

# Cloning and building it directly from git
RUN git clone --recurse-submodules https://github.com/sogno-platform/dpsim.git && \
    cd dpsim && \
	python3 ./setup.py \
		build_ext -j $(nproc) \
		bdist_wheel && \
	mkdir /temp/ && \
	cp dist/*.whl /temp/

FROM ${BASE_IMAGE}
USER root

# Toolchain
RUN apt-get update && \
	apt-get -y install \
		g++ git make cmake \
		libeigen3-dev \
		libgraphviz-dev \
		libgsl-dev \
		pybind11-dev \
		libxml2-dev \
		libsundials-dev \
		libfmt-dev \
		libspdlog-dev && \
	rm -rf /var/lib/apt/lists/*

RUN mkdir /build
WORKDIR /build

# Install CIM++
RUN git clone --recursive https://github.com/cim-iec/libcimpp.git && \
	mkdir build_libcimpp && \
	cd build_libcimpp && \
	cmake ../libcimpp \
		-DUSE_CIM_VERSION=CGMES_2.4.15_16FEB2016 \
		-DBUILD_SHARED_LIBS=ON \
		-DCMAKE_POSITION_INDEPENDENT_CODE=ON && \
	make -j$(nproc) install && \
	cd .. && \
	rm -rf build_libcimpp libcimpp

# Update the libraries
RUN ldconfig

USER ${NB_USER}
WORKDIR /home/${NB_USER}

RUN git clone https://git-ce.rwth-aachen.de/acs/private/personal-research/carreras/students/teaching/mtdi/jch/notebooks-mtdi.git && \
	cd notebooks-mtdi && \
	git checkout add-files

RUN cd notebooks-mtdi
# Install packages via requirements.txt
COPY requirements.txt .

# Copy dpsim wheel package from base container & install the packages
COPY --from=base /temp/*.whl /tmp/
RUN	pip install /tmp/*.whl && \
	pip install -r requirements.txt

# .. Or update conda base environment to match specifications in environment.yml
COPY environment.yml /tmp/environment.yml

# All packages specified in environment.yml are installed in the base environment
# RUN conda env update -f /tmp/environment.yml && \
#     conda clean -a -f -y



# Copy the practice session files
COPY Practice_Sessions/ /Practice_Sessions/
RUN ls -la .

#Add git clone for the correct repo url
