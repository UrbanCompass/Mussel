//  Copyright © 2020 Compass. All rights reserved.

import Foundation

public class Errno {
    public class func description() -> String {
        return String(cString: strerror(errno))
    }
}
