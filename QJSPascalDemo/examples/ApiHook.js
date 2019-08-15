// custom log function.
log('')

const ExitProcess = new Cmu.ApiHook(); // Create From Our Module

ExitProcess.OnCallBack = function (Emu, API,ret) {

	console.log("Hello From ExitProcess",ExitProcess.version);
	return true;
};
ExitProcess.install('kernel32.dll', 'FatalExit');


log('\n====================================================\n')

const MessageBox = new ApiHook(); // From the Global context

MessageBox.OnCallBack = function (Emu, API,ret) {

	console.log("Hello From MessageBox",MessageBox.version);
	return false;
};
MessageBox.install('user32.dll', 'MessageBox');
