// Copyright © 2021 Compass. All rights reserved.

import Foundation

public class Errno {
    public class func description() -> String {
        String(cString: strerror(errno))
    }
}
