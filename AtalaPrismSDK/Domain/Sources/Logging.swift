/// The log level.
///
/// Log levels are ordered by their severity, with `.debug` being the least severe and
/// `.error` being the most severe. You can also pick `.none` for no logging.
/// `.info` is the default log level
public enum LogLevel: Int {
    /// Appropriate for messages that contain information normally of use only when
    /// debugging a program.
    case debug

    /// Appropriate for informational messages.
    case info

    /// Appropriate for conditions that are not error conditions, but that may require
    /// special handling.
    case notice

    /// Appropriate for messages that are not error conditions, but more severe than
    /// `.notice`.
    case warning

    /// Appropriate for error conditions.
    case error

    /// For no logging
    case none
}

/// Log component
///
/// This components identify a part of the SDK. You can set the component and its own log level.
/// This way you can debug single parts of the SDK.
public enum LogComponent: String {
    case apollo
    case castor
    case core
    case mercury
    case pluto
    case pollux
    case prismAgent
}
