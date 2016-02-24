package example;

public class Example {

	public String message() {
		return messageImpl();
	}


	native String messageImpl();
}
