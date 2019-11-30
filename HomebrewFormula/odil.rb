class Odil < Formula
  desc "A C++11 library for the DICOM standard"
  homepage "https://odil.readthedocs.io"
  url "https://github.com/lamyj/odil/archive/v0.10.0.tar.gz"
  sha256 "5dcac1e415a84af737970c2db7cde329220080c5aaae933917757772067050c8"
  head "https://github.com/lamyj/odil.git"

  option "without-python", "Build without python support"

  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "boost" => :build
  depends_on "dcmtk" => :build
  depends_on "icu4c" => :build
  depends_on "jsoncpp" => :build
  depends_on "pybind11" => :build
  depends_on "python" => :build
  
  def install
    ENV.cxx11
    
    ENV.append "LDFLAGS", "-undefined dynamic_lookup"
    ENV.prepend_path "PKG_CONFIG_PATH", Formula["icu4c"].opt_lib/"pkgconfig"
    ENV.delete "PYTHONPATH"
    
    args = std_cmake_args
    args << "-GNinja"
    # cf. https://github.com/Homebrew/homebrew-core/issues/44093
    args << "-DBoost_NO_BOOST_CMAKE=ON"
    
    if build.with?("python")
      python_executable = "/usr/local/bin/python3"
      python_prefix = `#{python_executable} -c 'import sys;print(sys.prefix)'`.chomp
      python_version = `#{python_executable} -c 'import sys;print(sys.version[:3])'`.chomp
      python_include_dir = `#{python_executable} -c 'from distutils import sysconfig;print(sysconfig.get_python_inc(True))'`.chomp
      python_library = "#{python_prefix}/lib/libpython#{python_version}.dylib"
      
      boost_python_library = "/usr/local/lib/libboost_python#{python_version.delete "."}.dylib"
      
      args << "-DBUILD_PYTHON_WRAPPERS=ON"
      args << "-DPYTHON_EXECUTABLE=#{python_executable}"
      args << "-DPYTHON_LIBRARY=#{python_library}"
      args << "-DPYTHON_INCLUDE_DIR=#{python_include_dir}"
      args << "-DBoost_PYTHON_LIBRARY_RELEASE=#{boost_python_library}"
    else
      args << "-DBUILD_PYTHON_WRAPPERS=OFF"
    end
    
    mkdir "build" do
      system "cmake", "..", *args
      system "ninja", "install"
    end
  end
end
