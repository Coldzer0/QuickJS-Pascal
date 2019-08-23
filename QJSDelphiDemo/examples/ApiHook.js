// custom log function.
log('\n====================================================\n')

const ExitProcess = new Cmu.ApiHook(); // Create From Our Module

ExitProcess.OnCallBack = function (Emu, API,ret) {

	ExitProcess.args[0] = 1007;
	ExitProcess.args[1] = 2222;

	console.log("Hello From ExitProcess -",ExitProcess.version);

	return true;
};
ExitProcess.install('kernel32.dll', 'ExitProcess');

log('ExitProcess.args[0] : ',ExitProcess.args[0])
log('ExitProcess.args[1] : ',ExitProcess.args[1])


log('\n====================================================\n')

const MessageBox = new ApiHook(); // From the Global context

MessageBox.OnCallBack = function (Emu, API,ret) {

	MessageBox.args[0] = 'hello';
	MessageBox.args[1] = 1010;
	console.log("Hello From MessageBox",MessageBox.version);
	return false;
};
MessageBox.install('user32.dll', 'MessageBox');
log('MessageBox.args[0] : ',MessageBox.args[0])
log('MessageBox.args[1] : ',MessageBox.args[1])

