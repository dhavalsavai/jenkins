# Jenkins Agent Setup on Windows Server

This guide walks you through the setup of a Jenkins agent on a Windows server using WinSW (Windows Service Wrapper). It ensures the Jenkins agent runs as a Windows service and automatically reconnects after reboots or service interruptions.

## Prerequisites

- Java is installed on the system.
- Jenkins master server is set up.
- Jenkins agent JAR file (`agent.jar`) downloaded from your Jenkins server.
- Windows Server with administrative privileges.

## Setup Instructions

### Step 1: Download and Install WinSW

1. Download the latest **WinSW** executable from the [WinSW releases page](https://github.com/winsw/winsw/releases).
2. Rename the downloaded WinSW executable to `JenkinsAgent.exe`.
3. Move `JenkinsAgent.exe` to your Jenkins agent working directory, for example: `C:\Dhaval-Jenkins`.

### Step 2: Create the JenkinsAgent Configuration File

1. Navigate to the working directory (`C:\Dhaval-Jenkins`).
2. Create an XML file named `JenkinsAgent.xml`.
3. Add the following configuration to `JenkinsAgent.xml`:

   ```xml
   <service>
     <id>JenkinsAgent</id>
     <name>Jenkins Agent</name>
     <description>This is the Jenkins agent service for the 'dev' node.</description>
     <executable>java</executable>
     <arguments>-jar "C:\Dhaval-Jenkins\agent.jar" -jnlpUrl http://38.242.198.81:8080/computer/dev/slave-agent.jnlp -secret e9c24088c090fe18a2857f2d97f0e8bc13e69c3afff836021f1bfa68f306ea5c -workDir "C:\Dhaval-Jenkins"</arguments>
     <logpath>C:\Dhaval-Jenkins\logs</logpath>
     <startmode>Automatic</startmode>
   </service>

### Step 3: Install Jenkins Agent as a Windows Service

1. Install the service:
Use the following command to install the Jenkins agent as a Windows service:

.\JenkinsAgent.exe install

2. Start the service:
After the service is installed, you can start it using:

.\JenkinsAgent.exe start


3. Check the service status:
To check whether the service is running, use:

.\JenkinsAgent.exe status


now check jenkins and check agent is connected 
