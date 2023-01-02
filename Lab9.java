import com.espertech.esper.common.client.EPCompiled;
import com.espertech.esper.common.client.configuration.Configuration;
import com.espertech.esper.compiler.client.CompilerArguments;
import com.espertech.esper.compiler.client.EPCompileException;
import com.espertech.esper.compiler.client.EPCompilerProvider;
import com.espertech.esper.runtime.client.*;

import java.io.IOException;

public class Main {
    public static EPDeployment compileAndDeploy(EPRuntime epRuntime, String epl) {
        EPDeploymentService deploymentService = epRuntime.getDeploymentService();
        CompilerArguments args = new CompilerArguments(epRuntime.getConfigurationDeepCopy());
        EPDeployment deployment;
        try {
            EPCompiled epCompiled = EPCompilerProvider.getCompiler().compile(epl, args);
            deployment = deploymentService.deploy(epCompiled);
        } catch (EPCompileException e) {
            throw new RuntimeException(e);
        } catch (EPDeployException e) {
            throw new RuntimeException(e);
        }
        return deployment;
    }

    public static void main(String[] args) throws IOException {

        Configuration configuration = new Configuration();
        configuration.getCommon().addEventType(KursAkcji.class);
        EPRuntime epRuntime = EPRuntimeProvider.getDefaultRuntime(configuration);
        EPDeployment deployment = compileAndDeploy(epRuntime,
                "select ISTREAM data, spolka, kursOtwarcia - min(kursOtwarcia) as roznica " +
                        "from KursAkcji(spolka='Oracle').win:length(2) " +
                        "having kursOtwarcia > MIN(kursOtwarcia)"
        );

        ProstyListener prostyListener = new ProstyListener();

        for (EPStatement statement : deployment.getStatements()) {
            statement.addListener(prostyListener);
        }

        InputStream inputStream = new InputStream();
        inputStream.generuj(epRuntime.getEventService());
    }
}
/*
// Zad 24
"SELECT IRSTREAM spolka as X, kursOtwarcia as Y " +
"FROM KursAkcji.win:length(3) " +
"WHERE spolka = 'Oracle'"


// Zad 25
"SELECT IRSTREAM data, kursOtwarcia, spolka " +
"FROM KursAkcji.win:length(3) " +
"WHERE spolka = 'Oracle'"
	
// Zad 26
"SELECT IRSTREAM data, kursOtwarcia, spolka " +
"FROM KursAkcji(spolka='Oracle').win:length(3) "
	
// Zad 27
"SELECT ISTREAM data, kursOtwarcia, spolka " +
"FROM KursAkcji(spolka='Oracle').win:length(3) "

// Zad 28
"SELECT ISTREAM MAX(kursOtwarcia) " +
"FROM KursAkcji(spolka='Oracle').win:length(5) "

// Zad 29
"SELECT ISTREAM kursOtwarcia - MAX(kursOtwarcia) AS roznica " +
"FROM KursAkcji(spolka='Oracle').win:length(5) "
// Do funkcji max brane są wartości z okna (nie z całego zbioru)

// Zad 30
"SELECT ISTREAM data, spolka, kursOtwarcia - MIN(kursOtwarcia) AS roznica " +
"FROM KursAkcji(spolka='Oracle').win:length(2) " +
"HAVING kursOtwarcia > MIN(kursOtwarcia)"
// Widoczne są tylko wzrosty, wynik poprawny
*/
