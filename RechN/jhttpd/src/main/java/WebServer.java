import java.io.*;
import java.net.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.util.*;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.function.Function;
import java.util.logging.*;
import java.util.logging.Formatter;
import java.util.stream.Collectors;
import java.util.stream.Stream;

/**
 * Formats log records with the given String.format format.
 *
 * The arguments for the format are:
 * - date
 * - message
 * - backtrace, if there was an exception
 */
class FormatLogFormatter extends Formatter {
  private String format;

  public FormatLogFormatter(String format) {
    this.format = format;
  }

  @Override
  public String format(LogRecord record) {
    Date date = new Date(record.getMillis());
    String backtrace = "";

    if (record.getThrown() != null) {
      StringBuilder sb = new StringBuilder();
      sb.append(record.getThrown().getMessage());
      sb.append("\n");

      StringWriter sw = new StringWriter();
      PrintWriter pw = new PrintWriter(sw);
      record.getThrown().printStackTrace(pw);
      pw.close();

      sb.append(sw.toString());

      backtrace = sb.toString();
    }

    return String.format(this.format, date, record.getMessage(), backtrace);
  }
}

/**
 * Log messages in a single line (in contrast to the verbose format of
 * java.util.logging.SimpleFormatter)
 */
class SingleLineFormatter extends FormatLogFormatter {
  public SingleLineFormatter() {
    super("%1$tD %1$tT - %2$s%3$s\n");
  }
}

/**
 * Transform the MIME type file into a map (Ending -> MIME type)
 */
class MimeFileParser {
  public Map<String, String> parse(String filename) throws IOException {
    Function<String, List<String>> split = (line) -> {
      StringTokenizer tokenizer = new StringTokenizer(line);
      List<String> tokens = new ArrayList<>();

      while (tokenizer.hasMoreTokens()) {
        tokens.add(tokenizer.nextToken());
      }

      return tokens;
    };

    /**
     * Flattens a list of (type, ending1, ending2, ...) to ((type, ending1), (type, ending2), ...)
     */
    Function<List<String>, Stream<List<String>>> flatten = (tokens) -> {
      String type = tokens.remove(0);

      return tokens.stream().map((token) -> Arrays.asList(type, token));
    };

    Path path = Paths.get(filename);

    return Files.lines(path)
      .filter((line) -> !line.startsWith("#"))
      .map(split)
      .filter((list) -> list.size() >= 2)
      .flatMap(flatten)
      .collect(Collectors.toMap((pair) -> pair.get(1), (pair) -> pair.get(0), (u, v) -> u));
  }
}

/**
 * Root class for all exceptions in this package
 */
class HTTPException extends Exception {
  public HTTPException() {
    super();
  }

  public HTTPException(Throwable cause) {
    super(cause);
  }
}

/**
 * Something went wrong on the transport layer (TCP socket)
 */
class TransportException extends HTTPException {
  public TransportException(Throwable cause) {
    super(cause);
  }
}

/**
 * The incoming request is invalid and cannot be parsed into a Request object
 */
class InvalidRequestException extends HTTPException {
  public InvalidRequestException() {
    super();
  }

  public InvalidRequestException(Throwable cause) {
    super(cause);
  }
}

/**
 * An HTTP request
 */
class Request {
  /**
   * Request method (e.g. GET)
   */
  private final String method;

  /**
   * Request path (e.g. /some/path)
   */
  private final String path;

  /**
   * Request headers (e.g. (User-Agent -> "Mozilla", ...)
   */
  private final Map<String, String> headers;

  /**
   * Client address info
   */
  private final InetAddress clientAddress;

  public Request(String method, String path, Map<String, String> headers, InetAddress clientAddress) {
    this.method = method;
    this.path = path;
    this.headers = headers;
    this.clientAddress = clientAddress;
  }

  public String getMethod() {
    return method;
  }

  public String getPath() {
    return path;
  }

  public Map<String, String> getHeaders() {
    return headers;
  }

  public InetAddress getClientAddress() {
    return clientAddress;
  }

  /**
   * Read from the given reader and transform it into a Request object
   */
  public static Request read(BufferedReader reader, InetAddress clientAddress) throws IOException, InvalidRequestException {
    String requestLine = reader.readLine();

    if (requestLine == null) {
      throw new InvalidRequestException();
    }

    StringTokenizer requestTokenizer = new StringTokenizer(requestLine);
    String method;
    String path;

    try {
      method = requestTokenizer.nextToken();
      path = URLDecoder.decode(requestTokenizer.nextToken(), StandardCharsets.UTF_8.name());
    } catch (NoSuchElementException e) {
      throw new InvalidRequestException(e);
    }

    Map<String, String> headers = new HashMap<>();
    boolean headersLeft = true;

    while (headersLeft) {
      String line = reader.readLine();

      if (line == null || line.length() == 0) {
        headersLeft = false;
      } else {
        String[] parts = line.split(": ", 2);

        if (parts.length == 1) {
          throw new InvalidRequestException();
        } else {
          String name = parts[0];
          String value = parts[1];

          headers.put(name, value);
        }
      }
    }

    return new Request(method, path, headers, clientAddress);
  }
}

/**
 * HTTP status codes
 */
enum Status {
  OK(200, "OK"),
  CREATED(201, "Created"),
  ACCEPTED(202, "Accepted"),
  NO_CONTENT(204, "No Content"),
  MOVED_PERMANENTLY(301, "Moved Permanently"),
  MOVED_TEMPORARILY(302, "Moved Temporarily"),
  NOT_MODIFIED(304, "Not Modified"),
  BAD_REQUEST(400, "Bad Request"),
  UNAUTHORIZED(401, "Unauthorized"),
  FORBIDDEN(403, "Forbidden"),
  NOT_FOUND(404, "Not Found"),
  INTERNAL_SERVER_ERROR(500, "Internal Server Error"),
  NOT_IMPLEMENTED(501, "Not Implemented"),
  BAD_GATEWAY(502, "Bad Gateway"),
  SERVICE_UNAVAILABLE(503, "Service Unavailable");

  private final int code;

  private final String reason;

  Status(int code, String reason) {
    this.code = code;
    this.reason = reason;
  }

  public int getCode() {
    return code;
  }

  public String getReason() {
    return reason;
  }
}

/**
 * An HTTP response
 */
class Response {
  /**
   * Response status
   */
  private final Status status;

  /**
   * Response headers (e.g. (Content-Type -> image/png, ...))
   */
  private final Map<String, String> headers;

  /**
   * Response body
   *
   * May be null.
   */
  private InputStream body;

  public Response(Status status) {
    this(status, Collections.emptyMap());
  }

  public Response(Status status, Map<String, String> headers) {
    this(status, headers, null);
  }

  public Response(Status status, Map<String, String> headers, InputStream body) {
    this.status = status;
    this.headers = headers;
    this.body = body;
  }

  public Status getStatus() {
    return status;
  }

  public Map<String, String> getHeaders() {
    return headers;
  }

  public InputStream getBody() {
    return body;
  }

  public void setBody(InputStream body) {
    this.body = body;
  }

  /**
   * Write the response to an output stream, formatted according to HTTP1.0
   */
  public void writeTo(DataOutputStream stream) throws IOException {
    stream.writeBytes(String.format("HTTP/1.0 %d %s\r\n", this.status.getCode(), this.status.getReason()));

    for (Map.Entry<String, String> entry : this.headers.entrySet()) {
      stream.writeBytes(String.format("%s: %s\r\n", entry.getKey(), entry.getValue()));
    }

    stream.writeBytes("\r\n");

    if (this.body != null) {
      byte[] buffer = new byte[1024];
      int bytes;

      while ((bytes = this.body.read(buffer)) != -1) {
        stream.write(buffer, 0, bytes);
      }

      this.body.close();
    }
  }
}

/**
 * Shorthand for a 404 response
 */
class NotFoundResponse extends Response {
  public NotFoundResponse(Request request) {
    super(
      Status.NOT_FOUND,
      htmlHeader(),
      new ByteArrayInputStream(
        String
          .format(
            "<html><head></head><body><h1>Not Found</h1><p>Client IP: %s; User Agent: %s</p></body></html>",
            request.getClientAddress().getHostAddress(),
            classifyUserAgent(request.getHeaders().getOrDefault("User-Agent", "Unknown")))
          .getBytes(StandardCharsets.UTF_8)));
  }

  private static Map<String, String> htmlHeader() {
    Map<String, String> headers = new HashMap<>();
    headers.put("Content-Type", "text/html; charset=utf-8");

    return headers;
  }

  /**
   * Recognize some common browser by means of their user agent
   *
   * @see {https://developer.mozilla.org/en-US/docs/Browser_detection_using_the_user_agent}
   */
  private static String classifyUserAgent(String header) {
    if (header.contains("Chromium")) {
      return "Chromium";
    } else if (header.contains("Chrome")) {
      return "Chrome";
    } else if (header.contains("Firefox")) {
      return "Mozilla Firefox";
    } else if (header.contains("Safari")) {
      return "Safari";
    } else if (header.contains("OPR") || header.contains("Opera")) {
      return "Opera";
    } else if (header.contains("MSIE")) {
      return "Internet Explorer";
    } else {
      return String.format("Unknown (%s)", header);
    }
  }
}

/**
 * A client connection
 */
class Connection {
  private static Logger LOGGER = Logger.getLogger(Connection.class.getName());

  private static AtomicInteger CONNECTION_ID = new AtomicInteger(1);

  private final int id;

  private final Socket socket;

  Connection(Socket socket) {
    this.id = CONNECTION_ID.getAndIncrement();
    this.socket = socket;

    this.log(
      Level.INFO,
      String.format(
        "New connection from %s:%d",
        socket.getInetAddress().getHostAddress(),
        socket.getPort()));
  }

  /**
   * Read an HTTP1.0 request from the connection
   */
  public Request readHTTPRequest() throws TransportException, InvalidRequestException {
    InputStream stream;

    try {
      stream = this.socket.getInputStream();
    } catch (IOException e) {
      this.log(Level.WARNING, "Could not open a stream for reading");

      throw new TransportException(e);
    }

    BufferedReader reader = new BufferedReader(new InputStreamReader(stream));

    try {
      Request request = Request.read(reader, this.socket.getInetAddress());

      // Do not close reader and stream, because this would close the socket

      this.log(Level.INFO, String.format("%s %s", request.getMethod(), request.getPath()));

      return request;
    } catch (IOException e) {
      this.log(Level.WARNING, "Could not read from stream");

      throw new TransportException(e);
    }
  }

  /**
   * Send an HTTP1.0 response to the client
   */
  public void sendHTTPResponse(Response response) throws TransportException {
    this.log(Level.INFO, String.format("%d %s", response.getStatus().getCode(), response.getStatus().getReason()));

    OutputStream stream;

    try {
      stream = this.socket.getOutputStream();
    } catch (IOException e) {
      this.log(Level.WARNING, "Could not open a stream for writing");

      throw new TransportException(e);
    }

    DataOutputStream dataStream = new DataOutputStream(stream);

    try {
      response.writeTo(dataStream);

      dataStream.flush();
    } catch (IOException e) {
      this.log(Level.WARNING, "Could not send response");

      throw new TransportException(e);
    }

    try {
      dataStream.close();
      stream.close();
    } catch (IOException e) {
      throw new TransportException(e);
    }
  }

  /**
   * Close the connection
   */
  public void close() {
    try {
      // Shutdown to send a proper FIN-handshake instead of just RSTing
      this.socket.shutdownOutput();
      this.socket.close();

      this.log(Level.INFO, "Connection closed");
    } catch (IOException e) {
      this.log(Level.WARNING, "Could not close socket");
    }
  }

  private void log(Level level, String message) {
    LOGGER.log(level, String.format("#%d - %s", this.id, message));
  }
}

/**
 * Handles an HTTP request and generates a response
 */
interface RequestHandler {
  public Response handle(Request request);
}

/**
 * Serve files from a directory
 *
 * Resolves the request path relative to some root directory. If the resulting
 * path points to a file, send it. If it points to directory, list it's
 * contents.
 */
class FileRequestHandler implements RequestHandler {
  private static Logger LOGGER = Logger.getLogger(FileRequestHandler.class.getName());

  /**
   * Root directory to server files from
   */
  private final Path root;

  /**
   * MIME types, that this handler recognizes
   */
  private final Map<String, String> mimeTypes;

  /**
   * @param root Root directory to serve from
   * @param mimeTypes Recognized MIME types
   */
  public FileRequestHandler(Path root, Map<String, String> mimeTypes) {
    this.root = root;
    this.mimeTypes = mimeTypes;
  }

  @Override
  public Response handle(Request request) {
    Path path = this.root.resolve(String.format("./%s", request.getPath()));

    if (Files.exists(path)) {
      Map<String, String> headers = new HashMap<>();
      InputStream body;

      if (Files.isDirectory(path)) {
        DirectoryStream<Path> files;

        try {
          files = Files.newDirectoryStream(path);
        } catch (IOException e) {
          LOGGER.warning(String.format("Could not read directory %s", path.toString()));

          return new Response(Status.INTERNAL_SERVER_ERROR);
        }

        StringBuilder list = new StringBuilder();

        for (Path file : files) {
          try {
            list.append(
              String.format(
                "<li><a href=\"/%s\">%s</a></li>",
                URLEncoder.encode(
                  this.root.relativize(file).normalize().toString(),
                  StandardCharsets.UTF_8.name()),
                file.getFileName().toString()));
          } catch (UnsupportedEncodingException e) {
            // Ignore. UTF-8 is supported
          }
        }

        String html = String.format(
          "<html><head><title>%s</title></head><body><ul>%s</ul></body></html>",
          root.relativize(path),
          list.toString());

        headers.put("Content-Type", "text/html; charset=utf-8");

        body = new ByteArrayInputStream(html.getBytes(StandardCharsets.UTF_8));
      } else {
        try {
          File file = path.toFile();
          String extension = this.fileExtension(file.getName());

          headers.put("Content-Type", this.mimeTypes.getOrDefault(extension, "application/octet-stream"));
          body = new FileInputStream(file);
        } catch (FileNotFoundException e) {
          return new NotFoundResponse(request);
        }
      }

      return new Response(Status.OK, headers, body);
    } else {
      return new NotFoundResponse(request);
    }
  }

  /**
   * Returns the extension of a filename (e.g. "png" for "img.png")
   *
   * If the filename does not have an extension, return the filename.
   */
  private String fileExtension(String name) {
    int lastDot = name.lastIndexOf(".");

    return name.substring(Math.max(0, lastDot + 1));
  }
}

/**
 * A middleware wraps another handler and intercepts requests
 *
 * It could for example add a certain header to every response.
 */
abstract class Middleware implements RequestHandler {
  protected final RequestHandler handler;

  public Middleware(RequestHandler handler) {
    this.handler = handler;
  }
}

/**
 * Removes the body, if the request is a HEAD request
 */
class HEADHandler extends Middleware {
  private static Logger LOGGER = Logger.getLogger(HEADHandler.class.getName());

  public HEADHandler(RequestHandler handler) {
    super(handler);
  }

  @Override
  public Response handle(Request request) {
    Response response = this.handler.handle(request);

    if (request.getMethod().equals("HEAD")) {
      try {
        response.getBody().close();
      } catch (IOException e) {
        LOGGER.log(Level.WARNING, "Could not close body stream", e);
      }

      response.setBody(null);
    }

    return response;
  }
}

/**
 * Send a 501 Not Implemented response for POST requests
 */
class POSTHandler extends Middleware {
  public POSTHandler(RequestHandler handler) {
    super(handler);
  }

  @Override
  public Response handle(Request request) {
    if (request.getMethod().equals("POST")) {
      return new Response(Status.NOT_IMPLEMENTED);
    } else {
      return this.handler.handle(request);
    }
  }
}

/**
 * Handles the lifecycle of a connection
 *
 * Create -> read request -> handle -> send response -> close
 */
class ConnectionHandler implements Runnable {
  private static Logger LOGGER = Logger.getLogger(ConnectionHandler.class.getName());

  private final Socket socket;

  private final RequestHandler requestHandler;

  public ConnectionHandler(Socket socket, RequestHandler requestHandler) {
    this.socket = socket;
    this.requestHandler = requestHandler;
  }

  @Override
  public void run() {
    Connection connection = new Connection(this.socket);

    try {
      Request request = connection.readHTTPRequest();
      Response response = this.requestHandler.handle(request);
      connection.sendHTTPResponse(response);
    } catch (TransportException e) {
      LOGGER.warning("Something went wrong on the socket level");
    } catch (InvalidRequestException e) {
      try {
        connection.sendHTTPResponse(new Response(Status.BAD_REQUEST));
      } catch (TransportException e1) {
        LOGGER.warning("Something went wrong on the socket level");
      }
    }

    connection.close();
  }
}

/**
 * The real HTTP server
 *
 * This manages the server socket and accepts incoming connections.
 */
class HTTPServer {
  private static Logger LOGGER = Logger.getLogger(HTTPServer.class.getName());

  private final int port;

  private final RequestHandler requestHandler;

  public HTTPServer(int port, RequestHandler requestHandler) {
    this.port = port;
    this.requestHandler = requestHandler;
  }

  /**
   * Listen on the given port and accept incoming connections
   */
  public void run() {
    ServerSocket serverSocket;

    try {
      serverSocket = new ServerSocket(this.port);
    } catch (IOException e) {
      LOGGER.log(Level.SEVERE, "Could not create server socket", e);

      System.exit(1);
      return;
    }

    LOGGER.info(String.format("Listening on %s:%d", serverSocket.getInetAddress().toString(), serverSocket.getLocalPort()));

    while (true) {
      Socket socket = null;

      try {
        socket = serverSocket.accept();
      } catch (IOException e) {
        LOGGER.log(Level.WARNING, "Error while accepting connection", e);
      }

      if (socket != null) {
        this.handleRequest(socket);
      }
    }
  }

  /**
   * Handle a request in it's own thread
   */
  private void handleRequest(Socket socket) {
    ConnectionHandler handler = new ConnectionHandler(socket, this.requestHandler);

    Thread thread = new Thread(handler);
    thread.start();
  }
}

/**
 * The command line interface
 *
 * Reads command line arguments and configures the web server accordingly.
 */
public class WebServer {
  static Logger LOGGER = Logger.getLogger(WebServer.class.getName());
  static MimeFileParser MIME_PARSER = new MimeFileParser();

  public static void main(String[] args) {
    setupLogging();

    Map<String, String> arguments = pairArguments(args);
    Map<String, String> mimeTypes = Collections.emptyMap();
    Path root;

    if (arguments.containsKey("-mime")) {
      String filename = arguments.get("-mime");

      try {
        mimeTypes = MIME_PARSER.parse(filename);
      } catch (IOException e) {
        LOGGER.severe(String.format("Could not parse %s", filename));
        System.exit(1);
      }
    }

    if (arguments.containsKey("-path")) {
      root = new File(arguments.get("-path")).toPath().toAbsolutePath();
    } else {
      root = new File(WebServer.class.getClassLoader().getResource("").getPath()).toPath();
    }

    RequestHandler requestHandler =
      new POSTHandler(
        new HEADHandler(
          new FileRequestHandler(root, mimeTypes)));

    HTTPServer server = new HTTPServer(6789, requestHandler);

    server.run();
  }

  /**
   * Install our custom log formatter
   */
  private static void setupLogging() {
    Logger root = Logger.getLogger("");

    for (Handler handler : root.getHandlers()) {
      root.removeHandler(handler);
    }

    ConsoleHandler handler = new ConsoleHandler();
    handler.setFormatter(new SingleLineFormatter());

    root.addHandler(handler);
  }

  /**
   * Transform an array of arguments (arg1, arg2, arg3, arg4, ...)
   * into a map ((arg1 -> arg2), (arg3 -> arg4), ...)
   */
  private static Map<String, String> pairArguments(String[] args) {
    Map<String, String> pairs = new HashMap<>();

    for (int i = 0; i < args.length; i = i + 2) {
      if ((i + 1) < args.length) {
        pairs.put(args[i], args[i + 1]);
      }
    }

    return pairs;
  }
}
