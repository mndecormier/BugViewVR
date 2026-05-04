using UnityEngine;
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
}