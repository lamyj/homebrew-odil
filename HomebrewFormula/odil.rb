class Odil < Formula
  desc "A C++11 library for the DICOM standard"
  homepage "https://odil.readthedocs.io"
  url "https://github.com/lamyj/odil/archive/v0.12.0.tar.gz"
  sha256 "001448ea18ce593ded5744b8755845520f71bbc9571dcee25161fe4cab936693"
  head "https://github.com/lamyj/odil.git"
  
  bottle do
    root_url "https://dl.bintray.com/lamyj/generic/bottles"
    cellar :any
    sha256 "eff3c49ea3941ee3ce0d2e3e7d9d72a7d787e2a900d05d2f3948f35d846b2dcf" => :mojave
  end
  
  option "without-python", "Build without python support"

  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "boost"
  depends_on "dcmtk"
  depends_on "icu4c"
  depends_on "jsoncpp"
  depends_on "pybind11" => :build
  depends_on "python"
  
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
      
      args << "-DBUILD_PYTHON_WRAPPERS=ON"
      args << "-DPYTHON_EXECUTABLE=#{python_executable}"
      args << "-DPYTHON_LIBRARY=#{python_library}"
      args << "-DPYTHON_INCLUDE_DIR=#{python_include_dir}"
    else
      args << "-DBUILD_PYTHON_WRAPPERS=OFF"
    end
    
    mkdir "build" do
      system "cmake", "..", *args
      system "cmake", "--build", ".", "--target", "install"
    end
  end

  test do
    system "#{bin}/odil", "--help"
  end
end
