/*using UnityEngine;
using UnityEngine.SceneManagement;

public class BugSelector : MonoBehaviour
{
    public void LoadFly()
    {
        SceneManager.LoadScene("fly-view");
    }

    public void LoadButterfly()
    {
        SceneManager.LoadScene("butterfly-view");
    }

    public void LoadMosquito()
    {
        SceneManager.LoadScene("mosquito-view");
    }
}*/

using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

public class BugSelector : MonoBehaviour
{
    [SerializeField] private Button flyButton;
    [SerializeField] private Button butterflyButton;
    [SerializeField] private Button mosquitoButton;

    void Awake()
    {
        flyButton.onClick.AddListener(() => {
            Debug.Log("Fly clicked!");
            SceneManager.LoadScene("fly-view");
        });

        butterflyButton.onClick.AddListener(() => {
            Debug.Log("Butterfly clicked!");
            SceneManager.LoadScene("butterfly-view");
        });

        mosquitoButton.onClick.AddListener(() => {
            Debug.Log("Mosquito clicked!");
            SceneManager.LoadScene("mosquito-view");
        });
    }
}