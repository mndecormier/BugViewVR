using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.InputSystem;

public class ExitToMenu : MonoBehaviour
{
    [SerializeField] private string mainMenuScene = "finalvrproject";

    void Update()
    {
        // Any button on either controller returns to menu
        if (OVRInput.GetDown(OVRInput.Button.One))
        {
            Debug.Log("Controller button pressed — returning to menu");
            SceneManager.LoadScene(mainMenuScene);
        }
        if (OVRInput.GetDown(OVRInput.Button.PrimaryIndexTrigger))
        {
            Debug.Log("Controller button pressed — returning to menu");
            SceneManager.LoadScene(mainMenuScene);
        }
    }
}