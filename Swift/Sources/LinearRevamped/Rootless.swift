import libroot


// https://gist.github.com/leptos-null/4098d557ffab3d0edd8c1b4eab19c06d
func jbRootPath(_ cPath: UnsafePointer<CChar>?) -> String {
	String(unsafeUninitializedCapacity: Int(PATH_MAX)) { buffer in
		guard let resolved = libroot_dyn_jbrootpath(cPath, buffer.baseAddress) else { return 0 }
		return strlen(resolved)
	}
}

@_disfavoredOverload
func jbRootPath<S: StringProtocol>(_ path: S) -> String {
	path.withCString { cPath in
		jbRootPath(cPath)
	}
}
