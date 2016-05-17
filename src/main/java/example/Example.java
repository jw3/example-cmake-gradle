package example;

public class Example {

    public Example() {
        System.out.println("ctor called");
    }

	public String message() {

		System.out.println("calling message");
		return messageImpl();
	}

	native String messageImpl();

    static{ System.loadLibrary("libexample1"); }

	public static void main(String[] args){
	System.out.println(System.getProperty("java.library.path"));
	    System.out.println(new Example().message());
	}
}
