//
//  ProxyConfigurationViewController.swift
//  Potatso
//
//  Created by LEI on 3/4/16.
//  Copyright © 2016 TouchingApp. All rights reserved.
//

import UIKit
import Eureka
import PotatsoLibrary
import PotatsoModel

private let kProxyFormType = "type"
private let kProxyFormName = "name"
private let kProxyFormHost = "host"
private let kProxyFormPort = "port"
private let kProxyFormEncryption = "encryption"
private let kProxyFormPassword = "password"
private let kProxyFormOta = "ota"
private let kProxyFormObfs = "obfs"
private let kProxyFormObfsParam = "obfsParam"
private let kProxyFormProtocol = "protocol"


class ProxyConfigurationViewController: FormViewController {
    
    var upstreamProxy: Proxy
    let isEdit: Bool
    
    override convenience init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.init()
    }
    
    init(upstreamProxy: Proxy? = nil) {
        if let proxy = upstreamProxy {
            self.upstreamProxy = Proxy(value: proxy)
            self.isEdit = true
        }else {
            self.upstreamProxy = Proxy()
            self.isEdit = false
        }
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if isEdit {
            self.navigationItem.title = "Edit Proxy".localized()
        }else {
            self.navigationItem.title = "Add Proxy".localized()
        }
        generateForm()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(save))
    }
    
    func generateForm() {
        form +++ Section()
            <<< PushRow<ProxyType>(kProxyFormType) {
                $0.title = "Proxy Type".localized()
                $0.options = [ProxyType.Shadowsocks, ProxyType.ShadowsocksR, ProxyType.Subscribe]
                $0.value = self.upstreamProxy.type
                $0.selectorTitle = "Choose Proxy Type".localized()
            }
            <<< TextRow(kProxyFormName) {
                $0.title = "Name".localized()
                $0.value = self.upstreamProxy.name
                $0.hidden = Condition.function([kProxyFormType]) { form in
                    if let r1 : PushRow<ProxyType> = form.rowBy(tag: kProxyFormType), let isSubscribe = r1.value?.isSubscribe {
                        return isSubscribe
                    }
                    return false
                }
            }.cellSetup { cell, row in
                cell.textField.placeholder = "Proxy Name".localized()
            }
            <<< TextRow(kProxyFormHost) {
                $0.title = "Host".localized()
                $0.value = self.upstreamProxy.host
            }.cellSetup { cell, row in
                let values = self.form.values()
                let type = values[kProxyFormType] as? ProxyType
                switch type {
                case .Subscribe:
                    cell.textField.placeholder = "订阅地址"
                    break
                default:
                    cell.textField.placeholder = "Proxy Server Host".localized()
                    break
                }
                cell.textField.keyboardType = .URL
                cell.textField.autocorrectionType = .no
                cell.textField.autocapitalizationType = .none
            }
            <<< IntRow(kProxyFormPort) {
                $0.title = "Port".localized()
                $0.hidden = Condition.function([kProxyFormType]) { form in
                    if let r1 : PushRow<ProxyType> = form.rowBy(tag: kProxyFormType), let isSubscribe = r1.value?.isSubscribe {
                        return isSubscribe
                    }
                    return false
                }
                if self.upstreamProxy.port > 0 {
                    $0.value = self.upstreamProxy.port
                }
                let numberFormatter = NumberFormatter()
                numberFormatter.locale = .current
                numberFormatter.numberStyle = .none
                numberFormatter.minimumFractionDigits = 0
                $0.formatter = numberFormatter
                }.cellSetup { cell, row in
                    cell.textField.placeholder = "Proxy Server Port".localized()
            }
            <<< PushRow<String>(kProxyFormEncryption) {
                $0.title = "Encryption".localized()
                $0.options = Proxy.ssSupportedEncryption
                $0.value = self.upstreamProxy.authscheme ?? $0.options?[2]
                $0.selectorTitle = "Choose encryption method".localized()
                $0.hidden = Condition.function([kProxyFormType]) { form in
                    if let r1 : PushRow<ProxyType> = form.rowBy(tag: kProxyFormType), let isSS = r1.value?.isShadowsocks {
                        return !isSS
                    }
                    if let r1 : PushRow<ProxyType> = form.rowBy(tag: kProxyFormType), let isSubscribe = r1.value?.isSubscribe {
                        return isSubscribe
                    }
                    return false
                }
            }
            <<< PasswordRow(kProxyFormPassword) {
                $0.title = "Password".localized()
                $0.value = self.upstreamProxy.password ?? nil
                $0.hidden = Condition.function([kProxyFormType]) { form in
                    if let r1 : PushRow<ProxyType> = form.rowBy(tag: kProxyFormType), let isSubscribe = r1.value?.isSubscribe {
                        return isSubscribe
                    }
                    return false
                }
            }.cellSetup { cell, row in
                cell.textField.placeholder = "Proxy Password".localized()
            }
            <<< SwitchRow(kProxyFormOta) {
                $0.title = "One Time Auth".localized()
                $0.value = self.upstreamProxy.ota
                $0.hidden = Condition.function([kProxyFormType]) { form in
                    if let r1 : PushRow<ProxyType> = form.rowBy(tag: kProxyFormType) {
                        return r1.value != ProxyType.Shadowsocks
                    }
                    if let r1 : PushRow<ProxyType> = form.rowBy(tag: kProxyFormType), let isSubscribe = r1.value?.isSubscribe {
                        return isSubscribe
                    }
                    return false
                }
            }
            <<< PushRow<String>(kProxyFormProtocol) {
                $0.title = "Protocol".localized()
                $0.value = self.upstreamProxy.ssrProtocol
                $0.options = Proxy.ssrSupportedProtocol
                $0.selectorTitle = "Choose SSR protocol".localized()
                $0.hidden = Condition.function([kProxyFormType]) { form in
                    if let r1 : PushRow<ProxyType> = form.rowBy(tag: kProxyFormType) {
                        return r1.value != ProxyType.ShadowsocksR
                    }
                    if let r1 : PushRow<ProxyType> = form.rowBy(tag: kProxyFormType), let isSubscribe = r1.value?.isSubscribe {
                        return isSubscribe
                    }
                    return false
                }
            }
            <<< PushRow<String>(kProxyFormObfs) {
                $0.title = "Obfs".localized()
                $0.value = self.upstreamProxy.ssrObfs
                $0.options = Proxy.ssrSupportedObfs
                $0.selectorTitle = "Choose SSR obfs".localized()
                $0.hidden = Condition.function([kProxyFormType]) { form in
                    if let r1 : PushRow<ProxyType> = form.rowBy(tag: kProxyFormType) {
                        return r1.value != ProxyType.ShadowsocksR
                    }
                    if let r1 : PushRow<ProxyType> = form.rowBy(tag: kProxyFormType), let isSubscribe = r1.value?.isSubscribe {
                        return isSubscribe
                    }
                    return false
                }
            }
            <<< TextRow(kProxyFormObfsParam) {
                $0.title = "Obfs Param".localized()
                $0.value = self.upstreamProxy.ssrObfsParam
                $0.hidden = Condition.function([kProxyFormType]) { form in
                    if let r1 : PushRow<ProxyType> = form.rowBy(tag: kProxyFormType) {
                        return r1.value != ProxyType.ShadowsocksR
                    }
                    if let r1 : PushRow<ProxyType> = form.rowBy(tag: kProxyFormType), let isSubscribe = r1.value?.isSubscribe {
                        return isSubscribe
                    }
                    return false
                }
            }.cellSetup { cell, row in
                cell.textField.placeholder = "SSR Obfs Param".localized()
                cell.textField.autocorrectionType = .no
                cell.textField.autocapitalizationType = .none
            }

    }
    
    @objc func save() {
        do {
            let values = form.values()
            guard let type = values[kProxyFormType] as? ProxyType else {
                throw "You must choose a proxy type".localized()
            }
            if type == .Subscribe {
                guard let host = (values[kProxyFormHost] as? String)?.trimmingCharacters(in: CharacterSet.whitespaces), !host.isEmpty else {
                    throw "订阅地址不能为空"
                }
                showTextHUD("订阅", dismissAfterDelay: 1.0)
            } else {
                guard let name = (values[kProxyFormName] as? String)?.trimmingCharacters(in: CharacterSet.whitespaces), !name.isEmpty else {
                    throw "Name can't be empty".localized()
                }
                if !self.isEdit {
                    if let _ = defaultRealm.objects(Proxy.self).filter("name = '\(name)'").first {
                        throw "Name already exists".localized()
                    }
                }
                guard let host = (values[kProxyFormHost] as? String)?.trimmingCharacters(in: CharacterSet.whitespaces), !host.isEmpty else {
                    throw "Host can't be empty".localized()
                }
                guard let port = values[kProxyFormPort] as? Int else {
                    throw "Port can't be empty".localized()
                }
                guard port > 0 && port <= Int(UINT16_MAX) else {
                    throw "Invalid port".localized()
                }
                var authscheme: String?
                let user: String? = nil
                var password: String?
                switch type {
                case .Shadowsocks, .ShadowsocksR:
                    guard let encryption = values[kProxyFormEncryption] as? String, !encryption.isEmpty else {
                        throw "You must choose a encryption method".localized()
                    }
                    guard let pass = values[kProxyFormPassword] as? String, !pass.isEmpty else {
                        throw "Password can't be empty".localized()
                    }
                    authscheme = encryption
                    password = pass
                default:
                    break
                }
                let ota = values[kProxyFormOta] as? Bool ?? false
                upstreamProxy.type = type
                upstreamProxy.name = name
                upstreamProxy.host = host
                upstreamProxy.port = port
                upstreamProxy.authscheme = authscheme
                upstreamProxy.user = user
                upstreamProxy.password = password
                upstreamProxy.ota = ota
                upstreamProxy.ssrProtocol = values[kProxyFormProtocol] as? String
                upstreamProxy.ssrObfs = values[kProxyFormObfs] as? String
                upstreamProxy.ssrObfsParam = values[kProxyFormObfsParam] as? String
                try DBUtils.add(upstreamProxy)
                close()
            }
        }catch {
            showTextHUD("\(error)", dismissAfterDelay: 1.0)
        }
    }

}
