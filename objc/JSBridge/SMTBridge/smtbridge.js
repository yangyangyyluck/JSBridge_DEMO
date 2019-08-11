const SMT_BRIDGE_RESPONSE = "__SMT_BRIDGE_RESPONSE__";
const SMT_BRIDGE_LOADED = "smt://__loaded__";
const SMT_BRIDGE_MESSAGE = "smt://__message__";

class SMTBridge {
    constructor() {
        this.handlers = new Map();
        this.messages = [];
        this.callbacks = new Map();
        
        this.uniqueId = 1;
    }
    
    // native从该接口获取web的数据
    _sendMessages() {
        this._log('_sendMessages : ', this.messages);
        
        let messagesStr;
        try {
            messagesStr = JSON.stringify(this.messages);
        } catch (e) {
            this._error('<SMTBridge> json parse error : ', e);
            messagesStr = JSON.stringify([]);
        }
        
        this.messages = [];
        return messagesStr;
    }
    
    // web从该接口获取native的数据
    _getMessages(messagesJSON) {
        let messages;
        try {
            messages = JSON.parse(messagesJSON);
        } catch (e) {
            this._error('<SMTBridge> json parse error : ', e);
            messages = [];
        }
        
        this._log('_getMessages : ', messages);
        messages.forEach(message => this._handlerGetMessage(message));
    }
    
    // 处理message
    _handlerGetMessage(message) {
        const { type, data, callbackId, responseId } = message;
        
        // 处理response类型的message
        if (type === SMT_BRIDGE_RESPONSE) {
            const callback = this.callbacks.get(responseId);
            callback(data);
            this.callbacks.delete(responseId);
        } else {  // 处理普通类型的message
            let callback;
            if (callbackId) {
                // native端callback的wrapper
                callback = (data) => {
                    this._callHandler(SMT_BRIDGE_RESPONSE, data, callbackId);
                }
            }
            
            const handler = this.handlers.get(type);
            if (handler) {
                handler(data, callback);
            } else {
                this._error(`<SMTBridge> native called handler [${type}] does not register.`);
            }
        }
    }
    
    _triggerSend() {
        const iframe = document.createElement("iframe");
        iframe.src = SMT_BRIDGE_MESSAGE;
        iframe.style.display = 'none';
        document.documentElement.appendChild(iframe);
    }
    
    // helper
    _callbackId() {
        const id = 'js_' + (++this.uniqueId) + '_' + new Date().getTime() + '_' + Math.floor((Math.random() * 100));
        return id;
    }
    
    _log(...args) {
        console.log(...args);
    }
    
    _error(...args) {
        console.error(...args);
    }
    
    // Private APIs
    _callHandler(type, data, responseId) {
        let message = {
            type,
            data,
            responseId,
        };
        
        this.messages.push(message);
        
        setTimeout(() => {
                   this._triggerSend();
                   }, 0);
    }
    
    // APIs
    callHandler(type, data, callback) {
        let message = {
            type,
            data,
        };
        
        if (callback && (typeof callback === 'function')) {
            const callbackId = this._callbackId();
            this.callbacks.set(callbackId, callback);
            message.callbackId = callbackId;
        }
        
        this.messages.push(message);
        
        setTimeout(() => {
                   this._triggerSend();
                   }, 0);
    }
    
    registerHandler(type, cb) {
        this.handlers.set(type, cb);
    }
}

if (!window.smtBridge) {
    window.smtBridge = new SMTBridge();
    
    let event = new CustomEvent("smt_bridge_ready", { detail: window.smtBridge })
    document.dispatchEvent(event);
}
