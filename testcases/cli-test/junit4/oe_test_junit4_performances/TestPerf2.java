import org.junit.Test;

public class TestPerf2 {
	@Test(timeout=1000)
	public void testCalculate1() {
		Long l1 = 0L;
		Long l2 = 1L;
		Long l = 0L;  
		for (int i = 0; i < 100000; i++) {  
			l = l1 + l2;
			l1 = l2;
			l2 = l;
		}  
		System.out.println(l);
	}

	private static long getFibo(long i) {  
		if (i == 1 || i == 2){
			return 1L;  
		}else{
			return getFibo(i - 1) + getFibo(i - 2); 
		} 
	}

	@Test(timeout=1000)
	public void testCalculate2() {
		long o=getFibo(100000L);
		System.out.println(o);
	}
}

