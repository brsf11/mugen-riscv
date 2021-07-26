import org.testng.annotations.Listeners;
import org.testng.annotations.Test;

@Listeners(IHookableImp.class)
public class TExpListern {
	@Test
	public void test() {
		System.out.println("test method has been executed");
	}
}