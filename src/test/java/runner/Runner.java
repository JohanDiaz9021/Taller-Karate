package runner;

import com.intuit.karate.Results;
import static org.junit.jupiter.api.Assertions.*;
import org.junit.jupiter.api.Test;

class Runner {

    @Test
    void testParallel() {
        // parallel(1): el API guarda un único estado compartido, los escenarios no deben solaparse
        // Nombre completo: esta clase también se llama Runner y ocultaría com.intuit.karate.Runner
        Results results = com.intuit.karate.Runner.path("classpath:features")
                .reportDir("target/karate-reports")
                .outputCucumberJson(true)
                .parallel(1);

        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }
}
