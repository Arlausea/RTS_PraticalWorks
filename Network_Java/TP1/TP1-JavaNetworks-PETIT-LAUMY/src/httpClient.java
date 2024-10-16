import java.io.*;
import java.net.MalformedURLException;
import java.net.Socket;
import java.net.URL;

public class httpClient {

    private String protocol;
    private String host;
    private String filename;
    private int port;




    public void readURL(String[] args) throws MalformedURLException {

        String in = args[0];
        URL url = new URL(in);


        this.port = url.getPort();
        if (this.port == -1){ //Port not defined in the URL
            this.port = url.getDefaultPort();
        }

        this.host = url.getHost();
        this.filename = url.getFile();
        if (this.filename.isEmpty() || this.filename.equals("/")){
            this.filename = "/rfc.txt";
        }
        this.protocol = url.getProtocol();

        //Debug prints
        System.out.println("Host: "+host);
        System.out.println("Port: "+port);
        System.out.println("filename: "+filename);
        System.out.println("Protocol: "+protocol);

    }

    public void getURL(){
        try  { //Socket is a risky operation, a try/Catch statement is needed
            Socket socket = new Socket(this.host,this.port);
            System.out.println("Socket is opened at host "+host+" with port "+port+".");
            Thread.sleep(2);



            PrintWriter to = new PrintWriter(socket.getOutputStream(),true);
            BufferedReader buffer = new BufferedReader(new InputStreamReader(socket.getInputStream()));

            //Write with care the HTTP Request. Don't forget \r\n at the end of each block.
            to.println("GET "+filename+" HTTP/1.1\r\nHost: "+host+"\r\nUser-Agent: Firefox\r\n\r");

            OutputStream out = new FileOutputStream("rfc2068.html");
            InputStream from = socket.getInputStream();

            byte[] buf = new byte[4096];
            int bytes_read;
            while ((bytes_read = from.read(buf)) != -1){
                out.write(buf,0,bytes_read);
            }
            buffer.close();
            to.close();
            out.close();
            socket.close();

        }
        catch (Exception e){
            System.out.println("Socket error.");
            throw new RuntimeException(e);
        }

    }

    public static void main(String[] args) throws MalformedURLException { //Exception asked by URL
        if (args.length == 0) { //At least one argument is needed
            System.out.println("Invalid Format, need at least one argument!");
        } else {
            httpClient client = new httpClient();
            client.readURL(args);
            client.getURL();

        }
    }
}
