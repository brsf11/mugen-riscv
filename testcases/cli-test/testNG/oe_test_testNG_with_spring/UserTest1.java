import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.testng.AbstractTestNGSpringContextTests;
import org.testng.annotations.Test;

@ContextConfiguration(locations = { "classpath:applicationContext.xml" })
public class UserTest1 extends AbstractTestNGSpringContextTests {
	@Autowired
	private User user;

	@Test
	public void oString() {
		user.printName();
	}
}