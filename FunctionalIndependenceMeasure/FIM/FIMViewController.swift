//
//  FIMViewController.swift
//  Functional Independence Measure
//
//  Created by 村中令 on 2021/12/07.
//

import UIKit

class FIMViewController: UIViewController {
    //　画面遷移で値を受け取る変数
    var fimUUID: UUID?

    let fimRepository = FIMRepository()

    var fim: FIM? {
        fimRepository.loadFIM(fimUUID: fimUUID!)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


}

extension FIMViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }


}
