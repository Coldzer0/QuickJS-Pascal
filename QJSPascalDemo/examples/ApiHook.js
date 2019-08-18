// custom log function.
log('\n====================================================\n')

const ExitProcess = new Cmu.ApiHook(); // Create From Our Module

ExitProcess.OnCallBack = function (Emu, API,ret) {

	ExitProcess.args[0] = 1007;

	console.log("Hello From ExitProcess",ExitProcess.version);

	return true;
};
ExitProcess.install('kernel32.dll', 'ExitProcess');

log('args[0] : ',ExitProcess.args[0])


log('\n====================================================\n')

const MessageBox = new ApiHook(); // From the Global context

MessageBox.OnCallBack = function (Emu, API,ret) {

	console.log("Hello From MessageBox",MessageBox.version);
	return false;
};
MessageBox.install('user32.dll', 'MessageBox');
