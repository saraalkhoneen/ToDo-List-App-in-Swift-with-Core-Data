import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    var tasks: [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        fetchTasks()
    }

    func fetchTasks() {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            do {
                tasks = try context.fetch(Task.fetchRequest())
                tableView.reloadData()
            } catch {
                print("Fetching Failed")
            }
        }
    }

    @IBAction func addTask(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "New Task", message: "Add a new task", preferredStyle: .alert)

        alertController.addTextField { (textField) in
            textField.placeholder = "Task Title"
        }

        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            if let title = alertController.textFields?.first?.text, !title.isEmpty {
                self?.saveTask(title: title)
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(addAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    func saveTask(title: String) {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            let newTask = Task(context: context)
            newTask.title = title
            (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
            fetchTasks()
        }
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)

        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.title

        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        task.managedObjectContext?.delete(task)
        fetchTasks()
    }
}
